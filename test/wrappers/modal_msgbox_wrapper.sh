#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
modal "msgbox 'Modal dialog' 'This is a modal dialog over a dimmed background'"
echo "EXIT=$?"
echo "RESULT=modal_dismissed"
