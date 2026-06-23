#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
RESULT=$(filepicker "Pick" "Choose a file" "." 5)
echo "EXIT=$?"
echo "RESULT=$RESULT"