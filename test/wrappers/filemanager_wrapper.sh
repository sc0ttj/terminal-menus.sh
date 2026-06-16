#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - filemanager"

# Use external preview script instead of the built-in one
. ./preview.sh

filemanager "Advanced file manager" "." 3
FM_EXIT=$?
echo "EXIT=$FM_EXIT"
echo "RESULT=$TUI_RESULT"