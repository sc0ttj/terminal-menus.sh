#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
echo 'Category,Amount' > /tmp/tui_test_budget.csv
echo 'Food,100' >> /tmp/tui_test_budget.csv
echo 'Rent,500' >> /tmp/tui_test_budget.csv
RESULT=$(spreadsheet "Budget" "/tmp/tui_test_budget.csv")
echo "EXIT=$?"
echo "RESULT=$RESULT"
rm -f /tmp/tui_test_budget.csv
