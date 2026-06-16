#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=palette
export PALETTE_WIDTH=40
export PALETTE_HEIGHT=8
export ANCHOR=br
export OK_LABEL="OK"
msgbox "Palette mode" "Testing palette layout mode"
echo "EXIT=$?"
echo "RESULT=dismissed"
