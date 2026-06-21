#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
radiolist "Radio" "Choose:" 2 "Low" "Medium" "High" > /dev/null
echo "EXIT=$?"