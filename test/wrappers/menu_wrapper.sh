#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
RESULT=$(menu "Menu" "Pick a fruit:" 2 "Apple" "Banana" "Cherry" "Date" "Elderberry")
echo "EXIT=$?"
echo "RESULT=$RESULT"
