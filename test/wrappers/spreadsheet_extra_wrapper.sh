#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - spreadsheet (extra keys)"
printf "Item,Price,Qty\nWidgets,10.00,5\nGadgets,25.00,3\n" > /tmp/tui_extra.csv
spreadsheet "Spreadsheet" "/tmp/tui_extra.csv"
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
rm -f /tmp/tui_extra.csv
