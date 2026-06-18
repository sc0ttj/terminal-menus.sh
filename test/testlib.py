"""Shared PTY test framework for terminal-menus.sh widgets.

Uses persistent PTY sessions (one per test class) via pty.fork()
to avoid per-test subprocess overhead. Walks wrappers from the
wrappers/ directory automatically.

Usage:
    from testlib import TuiTestCase, KEY

    class TestWidget(TuiTestCase):
        def test_something(self):
            stdout, rc = self.runner("wrappers/widget.sh", [KEY.ENTER])
            self.assert_result("expected", stdout)
"""
import os, subprocess, time, unittest, tempfile, select
import pty
import signal

COLS = 80
ROWS = 24

EXIT_MARKER = "EXIT="
RESULT_MARKER = "RESULT="


class KEY:
    ENTER = b"\r"
    ESCAPE = b"\x1b"
    TAB = b"\t"
    SPACE = b" "
    BACKSPACE = b"\x7f"
    DELETE = b"\x1b[3~"
    UP = b"\x1b[A"
    DOWN = b"\x1b[B"
    LEFT = b"\x1b[D"
    RIGHT = b"\x1b[C"
    HOME = b"\x1b[H"
    END = b"\x1b[F"
    PAGE_UP = b"\x1b[5~"
    PAGE_DOWN = b"\x1b[6~"

    @staticmethod
    def char(c):
        return c.encode() if isinstance(c, str) else c

    @staticmethod
    def text(s):
        return s.encode()


def assert_result(expected, stdout, msg=""):
    marker = f"{RESULT_MARKER}{expected}"
    assert marker in stdout, (
        f"{msg} -- expected RESULT={expected!r}, "
        f"got stdout (first 3000 chars):\n{stdout[:3000]}"
    )


def assert_exit(expected, stdout):
    marker = f"{EXIT_MARKER}{expected}"
    assert marker in stdout, (
        f"expected {marker}, got stdout:\n{stdout[:2000]}"
    )


def assert_in_output(pattern, stdout, msg=""):
    assert pattern in stdout, (
        f"{msg} -- expected {pattern!r} in output, "
        f"got:\n{stdout[:3000]}"
    )


def parse_result(stdout):
    result = None
    exit_code = None
    for line in stdout.splitlines():
        if line.startswith(RESULT_MARKER):
            result = line[len(RESULT_MARKER):].strip()
        elif line.startswith(EXIT_MARKER):
            try:
                exit_code = int(line[len(EXIT_MARKER):].strip())
            except ValueError:
                pass
    return result, exit_code


class PtySession:
    """Persistent PTY session shared across a test class.

    Uses pty.fork() to create one ash shell that runs all wrappers
    for a widget, avoiding per-test subprocess overhead.
    Each wrapper runs in a subshell that saves and restores stty,
    so terminal state is clean between tests.
    """

    def __init__(self, shell="ash", init_delay=0.05):
        self.shell = shell
        pid, self.fd = pty.fork()
        if pid == 0:
            os.execve("/bin/ash", [shell], os.environ)
            os._exit(1)
        self.child_pid = pid
        time.sleep(init_delay)
        self._send("stty -echo 2>/dev/null\n")
        time.sleep(0.02)
        self._flush()

    def _send(self, data):
        if isinstance(data, str):
            data = data.encode()
        os.write(self.fd, data)

    def _flush(self):
        try:
            while True:
                r, _, _ = select.select([self.fd], [], [], 0.01)
                if r:
                    os.read(self.fd, 4096)
                else:
                    break
        except (OSError, ValueError):
            pass

    def run(self, wrapper, keys=None, timeout=8, init_delay=0.05):
        """Run a widget wrapper in the shared session."""
        if not os.path.isabs(wrapper):
            wrapper = os.path.join(os.path.dirname(__file__), wrapper)
        abs_wrapper = wrapper
        tty_save = f"/tmp/_tty_save_{os.getpid()}"

        # save stty -> run wrapper -> restore stty -> delimiter
        cmd = (
            f"(stty -g > {tty_save} 2>/dev/null; "
            f"ash '{abs_wrapper}'; "
            f"stty \"$(cat {tty_save})\" 2>/dev/null; "
            f"rm -f {tty_save}); "
            f"echo '___END___'\n"
        )
        self._send(cmd)

        if keys:
            time.sleep(init_delay)
            ks = b"".join(k.encode() if isinstance(k, str) else k for k in keys)
            self._send(ks)

        output = b""
        end_time = time.time() + timeout
        while time.time() < end_time:
            r, _, _ = select.select([self.fd], [], [], 0.05)
            if r:
                try:
                    data = os.read(self.fd, 4096)
                except OSError:
                    break
                if not data:
                    break
                output += data
                if b"___END___" in output:
                    time.sleep(0.02)
                    try:
                        while True:
                            r, _, _ = select.select([self.fd], [], [], 0.01)
                            if r:
                                more = os.read(self.fd, 4096)
                                if not more:
                                    break
                                output += more
                            else:
                                break
                    except OSError:
                        pass
                    break

        decoded = output.decode("utf-8", errors="replace")

        rc = None
        for line in decoded.splitlines():
            if line.startswith("EXIT="):
                try:
                    rc = int(line.split("=", 1)[1].strip())
                except (ValueError, IndexError):
                    pass
                break

        return decoded, rc

    def close(self):
        try:
            self._send("exit\n")
            time.sleep(0.05)
            os.kill(self.child_pid, signal.SIGTERM)
            os.waitpid(self.child_pid, 0)
        except (OSError, ValueError):
            pass
        try:
            os.close(self.fd)
        except OSError:
            pass


class PtyRunner:
    """Legacy per-test PTY runner via `script` subprocess. Used as
    fallback when pty.fork() is unavailable."""

    def __init__(self, wrapper, shell=None, cols=COLS, rows=ROWS,
                 timeout=8, init_delay=0.3):
        self.wrapper = wrapper
        self.shell = shell or "ash"
        self.cols = cols
        self.rows = rows
        self.timeout = timeout
        self.init_delay = init_delay

    def _resolve_wrapper(self):
        wrapper = self.wrapper
        if not os.path.isabs(wrapper):
            wrapper = os.path.join(os.path.dirname(__file__), wrapper)
        if not os.path.exists(wrapper):
            raise FileNotFoundError(f"Wrapper not found: {wrapper}")
        return wrapper

    def run(self, keys=None, delay=0.04):
        wrapper = self._resolve_wrapper()
        shell = self.shell
        stdin_data = b""
        if keys:
            for k in keys:
                stdin_data += k.encode() if isinstance(k, str) else k

        cmd = [
            "script", "-q", "-c",
            f"COLUMNS={self.cols} LINES={self.rows} {shell} '{wrapper}'",
            "/dev/null"
        ]

        try:
            proc = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
            )
        except FileNotFoundError:
            env = os.environ.copy()
            env.update(COLUMNS=str(self.cols), LINES=str(self.rows))
            proc = subprocess.Popen(
                [shell, wrapper],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                env=env,
            )

        time.sleep(self.init_delay)

        try:
            stdout_bytes, _ = proc.communicate(
                input=stdin_data if stdin_data else None,
                timeout=self.timeout
            )
        except subprocess.TimeoutExpired:
            proc.kill()
            stdout_bytes, _ = proc.communicate(timeout=2)

        decoded = stdout_bytes.decode("utf-8", errors="replace")
        return decoded, proc.returncode


class TuiTestCase(unittest.TestCase):
    """Base class for widget integration tests.

    Uses one persistent PTY session (PtySession) per class,
    started in setUpClass and torn down in tearDownClass.
    Falls back to per-test PtyRunner if pty.fork() fails.
    """

    _shell = None

    @classmethod
    def setUpClass(cls):
        try:
            cls._session = PtySession(shell=cls._shell or "ash")
        except Exception:
            cls._session = None

    @classmethod
    def tearDownClass(cls):
        if hasattr(cls, '_session') and cls._session is not None:
            cls._session.close()
            cls._session = None

    def runner(self, wrapper, keys=None, timeout=8, init_delay=0.05):
        if (hasattr(self.__class__, '_session')
                and self.__class__._session is not None):
            return self.__class__._session.run(
                wrapper, keys, timeout, init_delay
            )
        r = PtyRunner(
            wrapper, shell=self._shell, timeout=timeout,
            init_delay=init_delay
        )
        return r.run(keys=keys)

    def assert_result(self, expected, stdout, msg=""):
        marker = f"{RESULT_MARKER}{expected}"
        self.assertIn(marker, stdout,
                      f"{msg} -- expected RESULT={expected!r}")

    def assert_exit(self, expected, stdout, msg=""):
        marker = f"{EXIT_MARKER}{expected}"
        self.assertIn(marker, stdout,
                      f"{msg} -- expected {marker}")

    def assert_in_output(self, pattern, stdout, msg=""):
        self.assertIn(pattern, stdout, msg)

    def assert_no_shell_errors(self, stdout, msg=""):
        for err in ("Syntax error", "not found", "unexpected",
                    "Bad substitution"):
            self.assertNotIn(err, stdout,
                             f"{msg} -- shell error {err!r} found in output")
