#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus-demo.sh
demo_passwordbox
echo "EXIT=$?"