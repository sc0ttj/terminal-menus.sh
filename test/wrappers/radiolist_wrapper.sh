#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
RESULT=$(radiolist "Radios" "Choose one:" 2 "Low" "Medium" "High")
echo "EXIT=$?"
echo "RESULT=$RESULT"
