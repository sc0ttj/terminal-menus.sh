#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - yesno (theming)"
export YES_LABEL="Indeed"
export NO_LABEL="Not really"

yesno "Theming demo" "Do you want to change UI colours?" 2
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"