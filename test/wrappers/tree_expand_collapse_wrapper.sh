#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - tree (expand/collapse)"
tree "File tree" "Select a file or directory:" 2 \
    "0|usr|/usr|true" \
    "1|bin|bin|false" \
    "2|bash|bash|false" \
    "2|ls|ls|false" \
    "1|lib|lib|false" \
    "2|python3|python3|false" \
    "0|etc|/etc|true" \
    "1|hostname|hostname|false"
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
