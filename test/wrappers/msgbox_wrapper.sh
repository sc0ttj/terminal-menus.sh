#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - msgbox"
export OK_LABEL="Let's Go!"
msgbox \
    "A widget with two buttons" \
    "This is a showcase of all widgets provided by this \n\`terminal-menus.sh\` library.\n \nEnjoy the show!"
echo "EXIT=$?"
echo "RESULT=dismissed"