#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
inputbox "Input" "Enter:" "foo" > /dev/null
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
