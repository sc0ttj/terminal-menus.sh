#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export CANCEL_LABEL="ABORT"
yesno "Cancel label test" "Button should say ABORT" 2
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
