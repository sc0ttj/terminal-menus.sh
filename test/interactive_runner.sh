#!/bin/sh
# test/interactive_runner.sh - Run TUI scripts in xterm under Xvfb with xdotool control
# Usage:
#   ./test/interactive_runner.sh <script-to-test> [driver-script]
#   ./test/interactive_runner.sh <script-to-test> < <key-commands>
#   cat driver | ./test/interactive_runner.sh <script-to-test>
# Terminal (default xterm with DejaVu Sans Mono 12pt), geometry (default 100x30), and display are configurable:
#   TERMINAL_CMD="xterm -fa 'DejaVu Sans Mono' -fs 12 -geometry 100x30" TERM_GEOMETRY=100x30 DISPLAY_NUM=99 ./interactive_runner.sh ...

DISPLAY_NUM="${DISPLAY_NUM:-99}"
export DISPLAY=":${DISPLAY_NUM}"
SCREENSHOT_DIR="/tmp/tui_tests/$(date +%s)"
SCRIPT="$1"
DRIVER="${2:-}"
TERMINAL_CMD="${TERMINAL_CMD:-xterm -bw 0 -bg '#222222' -fa 'DejaVu Sans Mono' -fs 12 -geometry 100x30}"
TERM_GEOMETRY="${TERM_GEOMETRY:-100x30}"
export TERM="xterm-256color"

[ -z "$SCRIPT" ] && {
    echo "Usage: $0 <script-to-test> [driver-script]"
    echo "  Runs script-to-test in $TERMINAL, sends keystrokes defined in driver-script"
    echo "  If driver-script omitted, reads keystroke commands from stdin"
    exit 1
}
[ ! -f "$SCRIPT" ] && { echo "Script not found: $SCRIPT"; exit 1; }
[ -n "$DRIVER" ] && [ ! -f "$DRIVER" ] && { echo "Driver not found: $DRIVER"; exit 1; }

mkdir -p "$SCREENSHOT_DIR"
echo "Screenshots: $SCREENSHOT_DIR"

# ---- Helper functions for driver scripts ----

_focus_win() {
    [ -z "$_XDO_WIN" ] && _XDO_WIN=$(xdotool search --classname "xterm" 2>/dev/null | tail -1)
    xdotool windowfocus "$_XDO_WIN" 2>/dev/null
}

send_key() {
    _focus_win
    xdotool key --clearmodifiers --delay 20 "$1"
    sleep 0.15
}

type_text() {
    _focus_win
    xdotool type --clearmodifiers --delay 15 "$1"
    sleep 0.15
}

screenshot() {
    local name="$1"
    local file="${SCREENSHOT_DIR}/${name}.png"
    _focus_win
    sleep 0.5
    # Find xterm child window (terminal text area, no window borders)
    local child_win=$(xwininfo -id "$_XDO_WIN" -tree 2>/dev/null | grep -E "^\s+0x" | head -1 | awk '{print $1}')
    if [ -n "$child_win" ]; then
        xwd -id "$child_win" -out "/tmp/xwd_capture_$$.xwd" 2>/dev/null
        convert "/tmp/xwd_capture_$$.xwd" "$file" 2>/dev/null
        rm -f "/tmp/xwd_capture_$$.xwd"
    fi
    # Fallback: scrot -u on parent window if child capture failed
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        scrot -u "$file" 2>/dev/null
    fi
    # Fallback: full-screen scrot if nothing else worked
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        scrot "$file" 2>/dev/null
    fi
    echo "[SS] $file"
}

wait_s() { sleep "$1"; }

enter() { send_key Return; }
tab() { send_key Tab; }
space() { send_key space; }
escape() { send_key Escape; }
up() { send_key Up; }
down() { send_key Down; }

# ---- Cleanup trap ----

cleanup() {
    echo ""
    echo "Done. Screenshots: $SCREENSHOT_DIR"
}
trap cleanup EXIT INT TERM

# ---- Start Xvfb ----

echo "Starting Xvfb on $DISPLAY_NUM..."
# 100x30 at ~19px/char, ~36px/line with 12pt DejaVu Sans Mono = ~1920x1080
Xvfb ":$DISPLAY_NUM" -screen 0 1920x1080x24 2>/dev/null &
XVFB_PID=$!
sleep 1

# ---- Start terminal ----

echo "Starting terminal with: $SCRIPT"
echo "Terminal command: $TERMINAL_CMD"
# Use sh -c to avoid eval issues with command substitution
sh -c "$TERMINAL_CMD -e \"$SCRIPT\"" 2>/dev/null &
TERM_PID=$!
sleep 2

# ---- Wait for window ----

WIN_ID=""
for i in 1 2 3 4 5; do
    # Search by PID to ensure we get the right xterm
    WIN_ID=$(xdotool search --pid "$TERM_PID" 2>/dev/null | tail -1)
    echo "[DEBUG] xdotool search --pid returned: $WIN_ID" >&2
    if [ -z "$WIN_ID" ]; then
        # Fallback to classname search
        WIN_ID=$(xdotool search --classname "xterm" 2>/dev/null | tail -1)
        echo "[DEBUG] xdotool search --classname returned: $WIN_ID" >&2
    fi
    [ -n "$WIN_ID" ] && break
    sleep 1
done

if [ -z "$WIN_ID" ]; then
    echo "ERROR: xterm window not found"
    kill $TERM_PID $XVFB_PID 2>/dev/null
    exit 1
fi

_XDO_WIN="$WIN_ID"
xdotool windowmove "$WIN_ID" 0 0 2>/dev/null
echo "$TERMINAL window active (id=$WIN_ID)"

# ---- Run driver ----

if [ -n "$DRIVER" ]; then
    echo "Running driver: $DRIVER"
    . "$DRIVER"
else
    echo "Reading keystroke commands from stdin..."
    while IFS= read -r line; do
        eval "$line" 2>/dev/null || echo "BAD: $line"
    done
fi

# ---- Wait for completion ----

# Wait for terminal process - use polling instead of wait to avoid subshell issues
TERM_EXIT=0
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    if ! kill -0 $TERM_PID 2>/dev/null; then
        TERM_EXIT=0
        break
    fi
    sleep 1
done
# If still running, force kill
if kill -0 $TERM_PID 2>/dev/null; then
    kill $TERM_PID 2>/dev/null
    sleep 1
    TERM_EXIT=1
fi
kill $XVFB_PID 2>/dev/null
exit $TERM_EXIT
