#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - tree"
export ENABLE_FILTER=true
TREE_RES=$(ENABLE_FILTER=true tree "Choose a file from the tree" "Select a file or directory:" 2 \
    "0|usr|/usr|true" \
    "1|bin|bin/|true" \
    "2|bash|bash|false" \
    "2|grep|grep|false" \
    "2|sed|sed|false" \
    "1|local|local/|true" \
    "2|share|share/|true" \
    "3|doc|doc/|true" \
    "4|man|manual.txt|false" \
    "1|lib|lib/|true" \
    "2|python|python3/|true" \
    "3|site-packages|site-packages/|true" \
    "4|requests|requests/|false" \
    "4|cryptography|cryptography/|false" \
    "0|var|/var|true" \
    "1|log|log/|true" \
    "2|syslog|syslog|false" \
    "2|messages|messages|false")
echo "EXIT=$?"
echo "RESULT=$TREE_RES"