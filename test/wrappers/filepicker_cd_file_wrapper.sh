#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - filepicker (cd file)"
export TUI_CD_FILE="/tmp/tui_cd_file_test.txt"
FILE_PICK=$(filepicker "File picker" "Choose a file" "." 2)
echo "EXIT=$?"
echo "RESULT=$FILE_PICK"
cat "$TUI_CD_FILE" 2>/dev/null && rm -f "$TUI_CD_FILE"
