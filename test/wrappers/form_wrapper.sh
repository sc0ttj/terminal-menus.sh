#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
RESULT=$(form "" "" \
    "> Name:name=$(whoami)" \
    "> Pass:pass" \
    "Country:" \
    "{ } France:france,=USA:usa,Spain:spain" \
    "Features:" \
    "[ ] SSH:ssh" \
    "[x] HTTPS:https" \
    "Deploy:" \
    "(*) Yes:yes" \
    "( ) No:no")
echo "EXIT=$?"
echo "RESULT=$RESULT"
