#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
echo 'App,Version,CMD' > /tmp/tui_test_ftable.csv
echo 'Alpha,1.0,echo alpha' >> /tmp/tui_test_ftable.csv
echo 'Beta,2.0,echo beta' >> /tmp/tui_test_ftable.csv
echo 'Gamma,3.0,echo gamma' >> /tmp/tui_test_ftable.csv
RESULT=$(filtertable "Filterable" "Type to search:" "/tmp/tui_test_ftable.csv" 3)
echo "EXIT=$?"
echo "RESULT=$RESULT"
rm -f /tmp/tui_test_ftable.csv
