#!/bin/sh
# test/interactive_runner.sh - Run TUI scripts in mlterm under Xvfb with xdotool control
# Usage:
#   ./test/interactive_runner.sh <script-to-test> [driver-script]
#   ./test/interactive_runner.sh <script-to-test> < <key-commands>
#   cat driver | ./test/interactive_runner.sh <script-to-test>
# Terminal (default mlterm), geometry (default 80x24), and display are configurable:
#   TERMINAL=xterm TERM_GEOMETRY=100x30 DISPLAY_NUM=99 ./interactive_runner.sh ...

DISPLAY_NUM="${DISPLAY_NUM:-99}"
export DISPLAY=":${DISPLAY_NUM}"
SCREENSHOT_DIR="/tmp/tui_tests/$(date +%s)"
SCRIPT="$1"
DRIVER="${2:-}"
TERMINAL="${TERMINAL:-mlterm}"
TERM_GEOMETRY="${TERM_GEOMETRY:-80x24}"

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
    [ -z "$_XDO_WIN" ] && _XDO_WIN=$(xdotool search --pid "$TERM_PID" 2>/dev/null | tail -1)
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
    sleep 0.1
    scrot -u "$file" 2>/dev/null
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
Xvfb ":$DISPLAY_NUM" -screen 0 1280x960x24 2>/dev/null &
XVFB_PID=$!
sleep 1

# ---- Start terminal ----

echo "Starting $TERMINAL ($TERM_GEOMETRY) with: $SCRIPT"
$TERMINAL -geometry "$TERM_GEOMETRY" -e "$SCRIPT" 2>/dev/null &
TERM_PID=$!
sleep 2

# ---- Wait for window ----

WIN_ID=""
for i in 1 2 3 4 5; do
    WIN_ID=$(xdotool search --pid "$TERM_PID" 2>/dev/null | tail -1)
    [ -n "$WIN_ID" ] && break
    sleep 1
done

if [ -z "$WIN_ID" ]; then
    echo "ERROR: $TERMINAL window not found"
    kill $TERM_PID $XVFB_PID 2>/dev/null
    exit 1
fi

_XDO_WIN="$WIN_ID"
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

wait $TERM_PID 2>/dev/null
TERM_EXIT=$?
kill $XVFB_PID 2>/dev/null
exit $TERM_EXIT
