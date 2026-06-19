#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
passwordbox "Pass" "Enter pass:" "secret" > /dev/null
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
