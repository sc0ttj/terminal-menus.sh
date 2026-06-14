#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
COUNTRIES="Algeria
Argentina
Australia
Austria
Belgium
Brazil
Canada
China
France
Germany
India
Japan
Mexico
Netherlands
Spain
UK
USA"
RESULT=$(filtermenu "Filter" "Type to filter:" 2 "$COUNTRIES")
echo "EXIT=$?"
echo "RESULT=$RESULT"
