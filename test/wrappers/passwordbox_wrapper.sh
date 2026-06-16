#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - passwordbox"
PASS=$(passwordbox "Enter you details" "password:" "ppp")
echo "EXIT=$?"
echo "RESULT=$PASS"