#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus-demo.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - demo"
"demo_$1"
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"