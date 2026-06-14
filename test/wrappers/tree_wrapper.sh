#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
RESULT=$(tree "Tree" "Choose a file or dir:" 2 \
    "0|usr|/usr|true" \
    "1|bin|bin/|true" \
    "2|bash|bash|false" \
    "1|share|share/|true" \
    "2|doc|doc/|true" \
    "3|readme|readme.txt|false")
echo "EXIT=$?"
echo "RESULT=$RESULT"
