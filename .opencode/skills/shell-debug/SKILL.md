---
name: shell-debug
description: Debug shell code using available tools (bash -x, ash -n, shellcheck, strace, stty). Use when diagnosing bugs, tracing execution, checking terminal state, or investigating TUI rendering issues.
---

# Shell Debugging

Available debugging tools: `bash`, `ash`, `dash`, `sh`, `shellcheck`, `strace`, `gdb`, `stty`, `tput`, `infocmp`.

## Syntax validation (always do this first)

```bash
bash -n terminal-menus.sh && echo "bash OK"
ash -n terminal-menus.sh && echo "ash OK"
```

## ShellCheck (static analysis)

```bash
shellcheck terminal-menus.sh
shellcheck -s bash terminal-menus.sh   # force bash mode
shellcheck -s dash terminal-menus.sh   # force POSIX/dash mode
```

## Execution tracing

Run a widget with execution trace to see every command:

```bash
# With line-by-line trace:
bash -x terminal-menus.sh -c 'source ./terminal-menus.sh; menu "Test" "Pick:" 2 "A" "B"'

# Custom PS4 for more context (file:line:function):
PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}: ' bash -x terminal-menus.sh -c '...'
```

## Trace a specific section (no subshells, inline)

Insert these around the suspect code block:
```bash
set -x  # enable trace
# ... suspect code ...
set +x  # disable trace
```

## Check terminal state (when TUI rendering goes wrong)

```bash
# Show current terminal settings
stty -a

# Reset terminal after a crashed TUI
stty sane
stty echo

# Query terminal size
stty size          # "rows cols"
tput lines         # rows
tput cols          # cols

# Check terminal capability
infocmp -x
echo "$TERM"
```

## Trace system calls during rendering (strace)

```bash
# Trace all write() syscalls to stderr (fd 2):
strace -e write -f -p $PID 2>&1 | grep 'write(2'

# Trace all terminal ioctl calls:
strace -e ioctl -f -p $PID 2>&1 | grep -i 'TIOC\|terminal\|size'

# Run a widget under strace from the start:
strace -e write -f bash -c 'source ./terminal-menus.sh; menu "T" "P:" 2 "A" "B"' 2>&1
```

## Debugging preview rendering issues

```bash
# Run preview function directly in current terminal:
source ./terminal-menus.sh
preview "/path/to/file" 5 20 40 0
```

## Common TUI debugging checklist

1. **Black text in screenshots** → missing `$FG_TEXT_ESC` before visible text in `printf`
2. **Stale/corrupt screen** → terminal wasn't reset: run `stty sane; tput cnorm; reset`
3. **Widget hangs** → `stty -echo` not paired with `stty echo` on exit
4. **SIGWINCH issues** → `handle_resize()` should redraw; check trap setup
5. **Incorrect layout** → check `MAX_WIDTH`/`MAX_HEIGHT` values, `_init_tui` was called
6. **Key not recognized** → check `_read_key` / `_read_str_timeout` and the `case "$key"` handler
