#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
textbox "" "Read file" "./terminal-menus.sh"
echo "EXIT=$?"
echo "RESULT=done"
