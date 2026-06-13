#!/usr/bin/env python3
"""Pty-based form output functional test.
Runs the form widget inside a pseudo-terminal, sends Enter to submit with defaults,
captures stdout and TUI_RESULT values, verifies they match expected output.
"""
import os, pty, select, sys, time

SCRIPT = os.path.join(os.path.dirname(__file__), "wrappers", "form_test.sh")
if not os.path.exists(SCRIPT):
    print(f"FAIL: wrapper not found: {SCRIPT}")
    sys.exit(1)

def run_test():
    shell = os.environ.get("SHELL")
    if shell:
        args = [shell, SCRIPT]
    else:
        args = [SCRIPT]
    pid, fd = pty.fork()
    if pid == 0:
        os.execvp(args[0], args)
        sys.exit(1)
    
    output = b""
    timeout = 5.0
    start = time.time()
    
    while True:
        elapsed = time.time() - start
        if elapsed > timeout:
            break
        r, _, _ = select.select([fd], [], [], 0.5)
        if r:
            try:
                data = os.read(fd, 4096)
            except OSError:
                break
            if not data:
                break
            output += data
            # Look for the form being ready (not perfect, but Enter will be queued)
            # We just wait enough time then send Enter
        if elapsed > 1.5:
            os.write(fd, b"\r")  # Enter submits form
            break
    
    # Wait for process to finish
    time.sleep(1.0)
    try:
        remaining = os.read(fd, 16384)
        output += remaining
    except OSError:
        pass
    
    os.close(fd)
    
    # Parse output - look for lines like key='value'
    decoded = output.decode("utf-8", errors="replace")
    print("=== Raw output ===")
    print(decoded[:2000])
    print("=== End ===")
    
    # Expected values from form_test.sh defaults:
    # User:user => user='(whoami output)'  (dynamic)
    # Password:password => password=''     (empty)
    # Country: text label => last_label='country'
    # dropdown => country='usa'            (USA is default, labeled =USA)
    # Ethernet:eth0 => eth0='false'        (unchecked)
    # Wifi:wlan0 => wlan0='true'           (checked)
    # Fibre:eth1 => eth1='false'           (unchecked)
    # "Enabled connections:" text label => last_label='enabled_connections'
    # (none of its checkboxes output to this label)
    # Deployment: text label => last_label='deployment'
    # (*) Production:prod => deployment='prod'  (selected radio)
    # ( ) Staging:stage => no output            (unselected radio)
    
    failures = 0
    checks = [
        ("wlan0='true'", "Wifi should be enabled"),
        ("eth0='false'", "Ethernet should be disabled"),
        ("eth1='false'", "Fibre should be disabled"),
        ("deployment='prod'", "Production should be selected"),
        ("country='usa'", "Country should default to USA"),
        ("password=''", "Password should be empty by default"),
        ("user='", "User should have a value"),
    ]
    
    for pattern, desc in checks:
        if pattern in decoded:
            print(f"  PASS: {desc} => found '{pattern}'")
        else:
            print(f"  FAIL: {desc} => missing '{pattern}'")
            failures += 1
    
    return failures

if __name__ == "__main__":
    result = run_test()
    sys.exit(result)
