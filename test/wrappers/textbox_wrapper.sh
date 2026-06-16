#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - textbox"
textbox "" "Read file: ./terminal-menus.sh" "./terminal-menus.sh"
echo "EXIT=$?"
echo "RESULT=viewed"