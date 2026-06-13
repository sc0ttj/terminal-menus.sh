#!/bin/sh
# test/wrappers/form_test.sh - Wrapper for form widget visual test
# Run via: ../interactive_runner.sh form_test.sh ../drivers/form_test.driver

cd "$(dirname "$0")/../.."
. ./terminal-menus.sh

TUI_MODE=classic form "" "" \
    "> User:user=$(whoami)" \
    ">* Password:password" \
    "Country:" \
    "{ } France:france,Ireland:ireland,Thailand:thailand,Denmark:denmark,=USA:usa" \
    "Enabled connections:" \
    "[ ] Ethernet:eth0" \
    "[x] Wifi:wlan0" \
    "[ ] Fibre:eth1" \
    "Deployment:" \
    "(*) Production:prod" \
    "( ) Staging:stage"
