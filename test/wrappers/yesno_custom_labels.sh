#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
YES_LABEL="Indeed"; NO_LABEL="Not really"
yesno "Labels" "Custom labels demo?" 1
echo "EXIT=$?"
