#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - filtermenu (cursor)"
COUNTRIES="Afghanistan,Albania,Algeria,Andorra,Angola,Argentina,Australia"
filtermenu "Type to filter..." "Pick a country" 3 "$COUNTRIES"
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
