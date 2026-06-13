#!/bin/sh
# test/wrappers/mainmenu_test.sh - Wrapper for mainmenu visual test
# Run via: ../interactive_runner.sh mainmenu_test.sh ../drivers/mainmenu_test.driver

cd "$(dirname "$0")/../.."
. ./terminal-menus.sh

CONF_FILE="/tmp/tui_mainmenu_test.conf"
: > "$CONF_FILE"

update_config() {
    [ -z "$1" ] && return
    touch "$CONF_FILE"
    echo "$1" | while IFS= read -r line; do
        [ -z "$line" ] && continue
        key="${line%%=*}"
        grep -v "^${key}=" "$CONF_FILE" > "${CONF_FILE}.tmp"
        echo "$line" >> "${CONF_FILE}.tmp"
        mv "${CONF_FILE}.tmp" "$CONF_FILE"
    done
}

echo 'Setting,Type,Value,Command' > /tmp/tui_settings.csv

# Write CSV rows with $TUI_RESULT literal (expanded at runtime by mainmenu eval)
echo 'Profile,inputbox,Text,TUI_MODE=bottom modal "inputbox '"'"'Profile'"'"' '"'"'Enter name:'"'"'" && update_config "profile=$TUI_RESULT" >> '"$CONF_FILE" >> /tmp/tui_settings.csv
echo 'Secret Key,passwordbox,Hidden,TUI_MODE=bottom modal "passwordbox '"'"''"'"' '"'"'Enter passkey:'"'"'" && update_config "passkey=$TUI_RESULT" >> '"$CONF_FILE" >> /tmp/tui_settings.csv

echo 'Title,Genre,Year,Command' > /tmp/tui_movies.csv
echo 'The Matrix,Action,1999,echo "Matrix playing"' >> /tmp/tui_movies.csv

echo 'Artist,Album,Year,Command' > /tmp/tui_music.csv
echo 'Pink Floyd,DSOTM,1973,echo "Playing PF"' >> /tmp/tui_music.csv

KODI_MENU="Movies:movies:/tmp/tui_movies.csv
Music:music:/tmp/tui_music.csv
Settings:settings:/tmp/tui_settings.csv"

TUI_PERSISTENT_FILTERS=true mainmenu "Media center" "" "$KODI_MENU" 3

rm -f /tmp/tui_settings.csv /tmp/tui_movies.csv /tmp/tui_music.csv "$CONF_FILE"
cleanup
