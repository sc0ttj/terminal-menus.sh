#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - msgbox (custom label)"
export OK_LABEL="Continue"
msgbox "Custom label" "OK button should say 'Continue'"
echo "EXIT=$?"
echo "RESULT=dismissed"
