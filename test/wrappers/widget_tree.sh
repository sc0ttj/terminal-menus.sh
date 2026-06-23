#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
set -- "0|usr|/usr|true" "1|bin|bin|true" "2|bash|bash|false"
ENABLE_FILTER=true tree "Tree" "Select:" 1 "$@" > /dev/null
echo "EXIT=$?"