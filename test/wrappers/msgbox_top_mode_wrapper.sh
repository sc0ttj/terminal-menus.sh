#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=top
export BACKTITLE="Top mode test"
export OK_LABEL="OK"
msgbox "Top mode" "Testing top layout mode"
echo "EXIT=$?"
echo "RESULT=dismissed"
