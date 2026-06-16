#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=bottom
export BACKTITLE="Bottom mode test"
export OK_LABEL="OK"
msgbox "Bottom mode" "Testing bottom layout mode"
echo "EXIT=$?"
echo "RESULT=dismissed"
