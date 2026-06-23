#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
TUI_EXTRA_KEYS="ctrl_x=modal \"infobox 'Extra' 'Ctrl-X pressed'\""
export TUI_EXTRA_KEYS
_parse_extra_keys
menu "Menu" "Extra keys test:" 2 "A" "B" "C" > /dev/null
echo "EXIT=$?"