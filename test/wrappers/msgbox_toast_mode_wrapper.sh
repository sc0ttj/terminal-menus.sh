#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=toast
export TOAST_WIDTH=40
export TOAST_HEIGHT=5
export OK_LABEL="OK"
msgbox "Toast mode" "Testing toast layout mode"
echo "EXIT=$?"
echo "RESULT=dismissed"
