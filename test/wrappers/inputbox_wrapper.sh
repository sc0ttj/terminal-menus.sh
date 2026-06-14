#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
RESULT=$(inputbox "Input" "Enter name:" "default_name")
echo "EXIT=$?"
echo "RESULT=$RESULT"
