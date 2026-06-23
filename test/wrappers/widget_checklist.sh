#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
checklist "Checklist" "Select:" 2 "Apple" "Banana" "Cherry" > /dev/null
echo "EXIT=$?"