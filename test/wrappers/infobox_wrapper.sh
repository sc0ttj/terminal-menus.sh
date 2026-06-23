#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus-demo.sh
demo_infobox
read -r _
echo "EXIT=$?"