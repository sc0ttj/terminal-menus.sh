#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
TEMP_LOG=$(mktemp /tmp/tui_test_tail.XXXXXX)
echo "Line 1: monitoring test entry" > "$TEMP_LOG"
echo "Line 2: another log entry" >> "$TEMP_LOG"
tailbox "" "Monitor" "$TEMP_LOG"
echo "EXIT=$?"
echo "RESULT=done"
rm -f "$TEMP_LOG"
