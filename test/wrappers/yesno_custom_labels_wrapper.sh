#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - yesno (custom labels)"
export YES_LABEL="Indeed"
export NO_LABEL="Not really"
yesno "Custom labels" "Buttons should say 'Indeed' and 'Not really'" 1
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
