#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - color theme test"
export BG_MAIN="10;10;10"
export FG_TEXT="200;200;200"
export BG_WIDGET="40;40;40"
export BG_ACTIVE="100;150;200"
export FG_HINT="100;100;100"
export FG_BACKTITLE="200;100;50"
export BG_BACKTITLE="20;20;20"
export OK_LABEL="OK"
msgbox "Color theme" "This tests custom color overrides via ENV vars"
echo "EXIT=$?"
echo "RESULT=dismissed"
