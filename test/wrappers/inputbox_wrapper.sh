#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - inputbox"
USER_NAME=$(inputbox "Enter you details" "Username:" "foo")
echo "EXIT=$?"
echo "RESULT=$USER_NAME"