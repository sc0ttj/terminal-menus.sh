#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - radiolist"
RADIO=$(radiolist "Choose only one" "Choose exactly one:" 2 "Low" "Medium" "High")
echo "EXIT=$?"
echo "RESULT=$RADIO"