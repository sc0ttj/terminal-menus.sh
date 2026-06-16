#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=custom
export TUI_WIDTH=50
export TUI_HEIGHT=15
export OK_LABEL="OK"
msgbox "Custom mode" "Testing custom layout mode with width=50 height=15"
echo "EXIT=$?"
echo "RESULT=dismissed"
