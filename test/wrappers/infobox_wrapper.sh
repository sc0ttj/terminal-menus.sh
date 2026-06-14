#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
infobox "Info" "Non-blocking info message"
echo "EXIT=$?"
echo "RESULT=displayed"
