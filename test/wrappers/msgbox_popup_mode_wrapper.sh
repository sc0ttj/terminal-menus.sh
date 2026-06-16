#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=popup
export BACKTITLE="Popup mode test"
export OK_LABEL="OK"
msgbox "Popup mode" "Testing popup layout mode"
echo "EXIT=$?"
echo "RESULT=dismissed"
