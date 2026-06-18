#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - mainmenu"
export TUI_PERSISTENT_FILTERS=true

CONF_FILE="/tmp/tui_app.conf"

# a helper function to write key=value pairs to a config
update_config() {
    local input="$1"
    [ -z "$input" ] && return
    touch "$CONF_FILE"
    echo "$input" | while IFS= read -r line; do
        [ -z "$line" ] && continue
        local key="${line%%=*}"
        grep -v "^${key}=" "$CONF_FILE" > "${CONF_FILE}.tmp"
        echo "$line" >> "${CONF_FILE}.tmp"
        mv "${CONF_FILE}.tmp" "$CONF_FILE"
    done
}

# Initialize empty config
: > "$CONF_FILE"

# --- 1. Movies CSV ---
{
    echo "Title,Genre,Year,Command"
    echo "The Matrix,Action,1999,echo 'Playing Matrix...'"
    for i in $(seq 1 5); do echo "Movie $i,Genre $i,202$i,echo 'Playing Movie $i...'"; done
} > /tmp/tui_movies.csv

# --- 2. Music CSV ---
{
    echo "Artist,Album,Year,Command"
    echo "Pink Floyd,The Dark Side of the Moon,1973,echo 'Playing Pink Floyd...'"
} > /tmp/tui_music.csv

# --- 3. Settings CSV ---
{
    echo "Setting,Type,Value,Command"
    echo "Profile,inputbox,Text,TUI_MODE=bottom modal \"inputbox 'Profile' 'Enter name:'\" && update_config \"profile=\$TUI_RESULT\" >> $CONF_FILE"
    echo "Secret Key,passwordbox,Hidden Text,TUI_MODE=bottom modal \"passwordbox '' 'Enter passkey:'\" && update_config \"passkey=\$TUI_RESULT\" >> $CONF_FILE"
    echo "Resume,yesno,Choice,TUI_MODE=bottom modal \"yesno 'Playback' 'Enable Resume?'\" && update_config \"resume_enabled=\$TUI_RESULT\" >> $CONF_FILE"
    echo "Subtitles,checklist,Multi,modal \"checklist 'Lang' 'Select:' 'EN' 'ES' 'FR'\" && update_config \"subs=\$TUI_RESULT\" >> $CONF_FILE"
    echo "Resolution,radiolist,Single,modal \"radiolist 'Quality' 'Set:' '4K' '1080p' '720p'\" && update_config \"res=\$TUI_RESULT\" >> $CONF_FILE"
    echo "Credentials,form,Details,modal \"form 'Auth' 'Login' '> User:user' '>* Pass:pass'\" && update_config \"\$TUI_RESULT\" >> $CONF_FILE"
    echo "---,---,---,---"
    echo "View Config,infobox,Current State,modal \"infobox 'Saved Settings' '\$(echo ' ' && sort -u $CONF_FILE)'\""
} > /tmp/tui_settings.csv

# --- 4. DSL Orchestrator ---
KODI_MENU="Movies:my mooovies:/tmp/tui_movies.csv
Music:tuuuunes:/tmp/tui_music.csv
Settings:settings:/tmp/tui_settings.csv"

# --- 5. Launch ---
TUI_PERSISTENT_FILTERS=true mainmenu "Media center" "" "$KODI_MENU" 1

echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"

# --- 6. Cleanup ---
rm -f /tmp/tui_movies.csv /tmp/tui_music.csv /tmp/tui_settings.csv "$CONF_FILE"