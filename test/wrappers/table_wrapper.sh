#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
echo 'Item,Price,Qty' > /tmp/tui_test_table.csv
echo 'Apple,1.00,10' >> /tmp/tui_test_table.csv
echo 'Banana,0.50,20' >> /tmp/tui_test_table.csv
echo 'Cherry,2.00,15' >> /tmp/tui_test_table.csv
RESULT=$(table "Table" "Pick an item" "/tmp/tui_test_table.csv" 3)
echo "EXIT=$?"
echo "RESULT=$RESULT"
rm -f /tmp/tui_test_table.csv
