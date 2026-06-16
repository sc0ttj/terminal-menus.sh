#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - configtree"
export ENABLE_FILTER=true
CONFIG_OUT=$(ENABLE_FILTER=true configtree "Configuration tree" "Choose your desired settings" 7 \
    "0|system|System Settings|true" \
    "1|network|[x] Networking|true" \
    "2|interface|Interface Type|true" \
    "3|eth|(*) Ethernet|false" \
    "3|wlan|( ) Wireless|false" \
    "2|dhcp|[x] Use DHCP|false" \
    "1|security|[ ] Security Suite|true" \
    "2|firewall|[x] Enable Firewall|true" \
    "3|logging|[ ] Log dropped packets|false" \
    "3|stealth|[x] Stealth Mode|false" \
    "2|selinux|SELinux State|true" \
    "3|enforce|(*) Enforcing|false" \
    "3|permiss|( ) Permissive|false" \
    "0|apps|Applications|true" \
    "1|web|[x] Web Server|true" \
    "2|type|Server Engine|true" \
    "3|nginx|(*) Nginx|false" \
    "3|apache|( ) Apache|false" \
    "2|ssl|[x] Enable SSL/TLS|false")
echo "EXIT=$?"
echo "RESULT=$CONFIG_OUT"