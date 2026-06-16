#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - menu"
CHOICE=$(menu "Choose an item" "Pick a fruit:" 2 "Apple" "Banana" "Cherry")
echo "EXIT=$?"
echo "RESULT=$CHOICE"