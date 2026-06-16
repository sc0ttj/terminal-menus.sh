#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - filepicker"
FILE_PICK=$(filepicker "File picker" "Choose a file" "." 2)
echo "EXIT=$?"
echo "RESULT=$FILE_PICK"