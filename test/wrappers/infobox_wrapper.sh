#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - infobox"
infobox "Welcome" "This is a demo.\n \nPlease wait 2 seconds."
sleep 3
echo "EXIT=$?"
echo "RESULT=displayed"