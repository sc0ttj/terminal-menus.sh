#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus-demo.sh
demo_gauge
read -r _
echo "EXIT=$?"