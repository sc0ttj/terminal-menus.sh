#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
modal "infobox 'Modal' 'Test popup'"
echo "EXIT=$?"