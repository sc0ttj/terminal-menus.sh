#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
RESULT=$(ENABLE_FILTER=true configtree "Config" "Choose settings:" 4 \
    "0|system|System|true" \
    "1|network|[x] Networking|true" \
    "2|dhcp|[x] DHCP|false" \
    "0|apps|Apps|true" \
    "1|web|[x] Web Server|true" \
    "2|ssl|[ ] SSL|false")
echo "EXIT=$?"
echo "RESULT=$RESULT"
