#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
yesno "Question" "Choose yes or no"
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
