#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - tree (no filter)"
TREE_RES=$(tree "Choose a file from the tree" "Select a file or directory:" 2 \
    "0|usr|/usr|true" \
    "1|bin|bin/|true" \
    "2|bash|bash|false" \
    "2|grep|grep|false" \
    "1|lib|lib/|true" \
    "2|python|python3/|true" \
    "0|var|/var|true" \
    "1|log|log/|true" \
    "2|syslog|syslog|false")
echo "EXIT=$?"
echo "RESULT=$TREE_RES"
