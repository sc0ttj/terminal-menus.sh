#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
RESULT=$(checklist "Checklist" "Select options:" 2 "Option 1" "Option 2" "Option 3" "Option 4")
echo "EXIT=$?"
echo "RESULT=$RESULT"
