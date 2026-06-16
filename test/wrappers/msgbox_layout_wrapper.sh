#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=centered
export BACKTITLE="terminal-menus.sh - msgbox (centered)"
msgbox "Centered layout" "This msgbox uses centered layout mode"
echo "EXIT=$?"
echo "RESULT=dismissed"
