#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus-demo.sh
demo_radiolist
echo "EXIT=$?"