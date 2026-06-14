#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
printf "25\n50\n75\n100\n" | gauge "Progress" "Loading..."
echo "EXIT=$?"
echo "RESULT=complete"
