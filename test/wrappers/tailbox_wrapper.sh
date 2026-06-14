#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
tailbox "" "Monitor" "/var/log/syslog" 2>/dev/null || tailbox "" "Monitor" "/var/log/system.log" 2>/dev/null || true
echo "EXIT=$?"
echo "RESULT=done"
