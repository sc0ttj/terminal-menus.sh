#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
msgbox "Test Title" "Test message body here"
echo "EXIT=$?"
echo "RESULT=dismissed"
