#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
textbox "View" "Scroll test" "./terminal-menus.sh" > /dev/null
echo "EXIT=$?"