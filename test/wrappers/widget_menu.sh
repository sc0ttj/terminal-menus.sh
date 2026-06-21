#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
menu "Menu" "Pick:" 2 "Apple" "Banana" "Cherry" > /dev/null
echo "EXIT=$?"