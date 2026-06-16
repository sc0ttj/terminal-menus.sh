#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - filtermenu"

COUNTRIES="Algeria
Argentina
Australia
Austria
Bangladesh
Belgium
Brazil
Canada
Chile
China
Colombia
Egypt
France
Germany
Greece
India
Indonesia
Iran
Italy
Japan
Kenya
Malaysia
Mexico
Netherlands
Nigeria
Pakistan
Peru
Philippines
Poland
Russia
Saudi Arabia
South Africa
South Korea
Spain
Sweden
Switzerland
Thailand
Turkey
United Kingdom
United States"

SEARCH=$(filtermenu "Type to filter or navigate up and down the list" "Type to filter countries" 3 "$COUNTRIES")
echo "EXIT=$?"
echo "RESULT=$SEARCH"