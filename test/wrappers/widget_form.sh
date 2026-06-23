#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
form "" "" \
    "> User:user=foo" \
    "> Password:password=pass" \
    "[ ] Enable:opt" \
    "(*) Yes:radio1" \
    "( ) No:radio2" > /dev/null
echo "EXIT=$?"