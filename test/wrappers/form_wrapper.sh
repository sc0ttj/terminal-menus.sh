#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - form"
FORM_OUT=$(form "" "" \
    "> User:user=$(whoami)" \
    ">* Password:password=pass" \
    "Country:" \
    "{ } France:france,Ireland:ireland,Thailand:thailand,Denmark:denmark,United Kingdom:uk,=USA:usa,South Africa:southafrica" \
    "Enabled connections:" \
    "[ ] Ethernet:eth0" \
    "[x] Wifi:wlan0" \
    "[ ] Fibre:eth1" \
    "Deployment:" \
    "(*) Production:prod" \
    "( ) Staging:stage")
echo "EXIT=$?"
echo "RESULT=$FORM_OUT"