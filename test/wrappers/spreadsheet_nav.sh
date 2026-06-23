#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
cat <<CSV > /tmp/_test_sheet.csv
Item,Price
Bread,2.50
Milk,3.00
Eggs,4.50
CSV
RESULT=$(spreadsheet "Sheet" "/tmp/_test_sheet.csv"); SS_EXIT=$?
echo "EXIT=$SS_EXIT"
echo "RESULT=$RESULT"
rm -f /tmp/_test_sheet.csv