#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - checklist"
CHKS=$(checklist "Choose multiple item" "Select multiple options:" 2 "Option 1" "Option 2" "Option 3")
echo "EXIT=$?"
echo "RESULT=$CHKS"