#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="Custom BACKTITLE title bar"
export OK_LABEL="OK"
msgbox "BACKTITLE test" "The top bar should show the custom BACKTITLE"
echo "EXIT=$?"
echo "RESULT=dismissed"
