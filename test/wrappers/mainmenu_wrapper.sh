#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
echo 'Setting,Type,Value,Command' > /tmp/tui_test_mm.csv
echo 'Profile,inputbox,Text,modal "inputbox '"'"'Profile'"'"' '"'"'Enter name:'"'"'"' >> /tmp/tui_test_mm.csv
echo 'Title,Genre,Year,Command' > /tmp/tui_test_mm_movies.csv
echo 'The Matrix,Action,1999,echo matrix' >> /tmp/tui_test_mm_movies.csv
MM_MENU="Settings:settings:/tmp/tui_test_mm.csv
Movies:movies:/tmp/tui_test_mm_movies.csv"
TUI_PERSISTENT_FILTERS=true mainmenu "Media" "" "$MM_MENU" 3
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
rm -f /tmp/tui_test_mm.csv /tmp/tui_test_mm_movies.csv
