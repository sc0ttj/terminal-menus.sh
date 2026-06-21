#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
cat <<CSV > /tmp/_test_table.csv
Name,Val,Cmd
Alpha,10,echo a
Beta,20,echo b
Gamma,30,echo c
CSV
table "Table" "Pick:" "/tmp/_test_table.csv" 1 > /dev/null
echo "EXIT=$?"
rm -f /tmp/_test_table.csv