#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - gauge"
(
    for i in $(seq 0 20 100); do
        echo $i
        sleep 0.3
    done
) | gauge "" "Uploading assets to a CDN or something..."
sleep 3
echo "EXIT=$?"
echo "RESULT=complete"