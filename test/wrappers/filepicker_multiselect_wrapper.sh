#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - filepicker (multiselect)"
FILE_PICK=$(filepicker "File picker" "Tab to multi-select" "." 2)
echo "EXIT=$?"
echo "RESULT=$FILE_PICK"
