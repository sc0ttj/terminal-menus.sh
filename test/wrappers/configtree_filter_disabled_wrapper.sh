#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - configtree (no filter)"
CONFIG_OUT=$(configtree "Configuration tree" "Choose your desired settings" 7 \
    "0|system|System Settings|true" \
    "1|network|[x] Networking|true" \
    "2|interface|Interface Type|true" \
    "3|eth|(*) Ethernet|false" \
    "3|wlan|( ) Wireless|false" \
    "1|security|[ ] Security Suite|true" \
    "2|firewall|[x] Enable Firewall|true")
echo "EXIT=$?"
echo "RESULT=$CONFIG_OUT"
