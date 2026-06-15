#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
echo 'Name,Type,Value,Command' > /tmp/tui_test_mm_quotes.csv
echo "O'Brien,inputbox,Text,modal inputbox" >> /tmp/tui_test_mm_quotes.csv
echo "D'Arcy,passwordbox,Secret,modal passwordbox" >> /tmp/tui_test_mm_quotes.csv
MM_MENU="QSettings:quotes:/tmp/tui_test_mm_quotes.csv"
TUI_PERSISTENT_FILTERS=true mainmenu "Quotes" "" "$MM_MENU" 3
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
rm -f /tmp/tui_test_mm_quotes.csv
