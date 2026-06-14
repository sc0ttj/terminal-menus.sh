"""Shared PTY test framework for terminal-menus.sh widgets.

Uses the `script` command (which creates a proper pty with controlling
terminal) to run widget wrappers, pipes keystrokes through stdin.

Usage:
    from testlib import TuiTestCase

    class TestWidget(TuiTestCase):
        def test_something(self):
            stdout, rc = self.runner("wrappers/widget.sh", [KEY.ENTER])
            self.assert_result("expected", stdout)
"""
import os, subprocess, time, unittest, tempfile

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


class PtyRunner:
    """Run a widget wrapper via `script` (proper pty with controlling terminal)."""

    def __init__(self, wrapper, shell=None, cols=COLS, rows=ROWS, timeout=8, init_delay=0.3):
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

        # Build input: keystrokes followed by a small delay
        stdin_data = b""
        if keys:
            for k in keys:
                stdin_data += k.encode() if isinstance(k, str) else k

        # Use script to create a proper pty with controlling terminal
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
            # script not available; fallback to direct subprocess
            env = os.environ.copy()
            env.update(COLUMNS=str(self.cols), LINES=str(self.rows))
            proc = subprocess.Popen(
                [shell, wrapper],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                env=env,
            )

        # Small delay for widget initialization before sending input
        time.sleep(self.init_delay)

        # Send keystrokes and wait for completion via communicate.
        # Using communicate(input=...) ensures stdin is closed AFTER writing,
        # so `script` doesn't kill the pty before the child can process input.
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
    """Base class for widget integration tests."""

    _shell = None

    def runner(self, wrapper, keys=None, timeout=8, init_delay=0.3):
        r = PtyRunner(wrapper, shell=self._shell, timeout=timeout, init_delay=init_delay)
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
