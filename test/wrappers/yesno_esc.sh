#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
yesno "Question" "Cancel me?" 2
echo "EXIT=$?"
