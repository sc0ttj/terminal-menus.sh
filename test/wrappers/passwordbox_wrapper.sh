#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
RESULT=$(passwordbox "Password" "Enter secret:" "secret123")
echo "EXIT=$?"
echo "RESULT=$RESULT"
