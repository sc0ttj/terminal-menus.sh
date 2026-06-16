#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - form (extra keys)"
form "Extra keys" "Testing additional key bindings" \
    "> username:user:root" \
    "* Features:features:" \
    "( ) Option A:radio_group:" \
    "(*) Option B:radio_group:" \
    "{ } theme:dropdown:light,dark"
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
