#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus-demo.sh
demo_texteditor
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"