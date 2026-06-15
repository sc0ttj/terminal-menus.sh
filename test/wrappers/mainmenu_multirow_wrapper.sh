#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
echo 'Title,Genre,Year,Command' > /tmp/tui_test_mm_multi.csv
echo 'Zed,Action,2020,echo zed' >> /tmp/tui_test_mm_multi.csv
echo 'Alpha,SciFi,2010,echo alpha' >> /tmp/tui_test_mm_multi.csv
echo 'Gamma,Drama,2015,echo gamma' >> /tmp/tui_test_mm_multi.csv
echo 'Beta,Comedy,2005,echo beta' >> /tmp/tui_test_mm_multi.csv
MM_MENU="Multi:multi:/tmp/tui_test_mm_multi.csv"
mainmenu "Multi" "" "$MM_MENU" 1
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
rm -f /tmp/tui_test_mm_multi.csv
