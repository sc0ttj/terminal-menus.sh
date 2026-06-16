#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=classic
export BACKTITLE="Classic mode test"
export OK_LABEL="OK"
msgbox "Classic mode" "Testing classic layout mode"
echo "EXIT=$?"
echo "RESULT=dismissed"
