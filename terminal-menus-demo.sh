#!/bin/bash
# terminal-menus-test.sh - Comprehensive Demo of the terminal-menus.sh TUI Library

# Source the library
. ./terminal-menus.sh

# ==============================================================================
# terminal-menus.sh WIDGET USAGE GUIDE (Demos)
# ==============================================================================

# 1. Message Box & Buttons
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 1 of 21 - msgbox"
OK_LABEL="Let's Go!"
msgbox "Welcome" "This script showcases all widgets in the terminal-menus.sh library.\nEnjoy!"



# 2. Info Box (Non-blocking)
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 2 of 21 - infobox"
infobox "Processing" "I'm an infobox.\n\nI shows messages, no buttons.\nUse me with sleep..."
sleep 2



# 3. TUI Modes
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 3 of 21 - yesno (modes)"

MODES=("centered" "classic" "fullscreen" "popup" "top" "bottom" "toast" "palette")
current_idx=0

while true; do
    TUI_MODE="${MODES[$current_idx]}"
    [[ "$TUI_MODE" == "centered" ]] && BACKTITLE="terminal-menus.sh demo 1 of 21 - TUI mode is: $TUI_MODE" || BACKTITLE=""
    
    if yesno "Layout Switcher" "Current mode: $TUI_MODE.\nSee next mode?" 2; then
        current_idx=$(( (current_idx + 1) % 8 ))
    else
        break
    fi
done
TUI_MODE="centered" # Reset to default for subsequent demos



# 4. Yes/No with theme switching
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 4 of 21 - yesno (Theming)"
YES_LABEL="Indeed"
NO_LABEL="Not really"

if yesno "Question" "Do you like TrueColor TUI interfaces?" 2; then
    # --- ON THE FLY THEME CHANGE ---
    BG_MAIN="20;40;60"      # Deep Navy
    BG_WIDGET="40;60;80"    # Steel Blue
    HL_BLUE="0;200;200"     # Cyan Highlight
    _init_tui
fi
YES_LABEL="YES"
NO_LABEL="No"



# 5. Input Box
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 5 of 21 - inputbox"
USER_NAME=$(inputbox "Identity" "Enter your username:" "foo")



# 6. Password Box
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 6 of 21 - passwordbox"
PASS=$(passwordbox "Security" "Enter a secret token:" "ppp")



# 7. Simple Menu
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 7 of 21 - menu"
CHOICE=$(menu "Simple Menu" "Pick a fruit:" 2 "Apple" "Banana" "Cherry")



# 8. Checklist
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 8 of 21 - checklist"
CHKS=$(checklist "Checklist" "Select multiple options:" 2 "Option 1" "Option 2" "Option 3")



# 9. Radiolist
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 9 of 21 - radiolist"
RADIO=$(radiolist "Radiolist" "Choose exactly one:" 2 "Low" "Medium" "High")



# 10. Filtermenu (Searchable)
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 10 of 21 - filtermenu"

COUNTRIES="Argentina
Australia
Brazil
Canada
China
Egypt
France
Germany
India
Italy
Japan
Mexico
Nigeria
Russia
South Africa
South Korea
Spain
Thailand
United Kingdom
United States"
SEARCH=$(filtermenu "Search" "Type to filter countries:" 3 "$COUNTRIES")



# 11. Gauge (Progress)
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 11 of 21 - gauge"
(
    for i in $(seq 0 20 100); do
        echo $i
        sleep 0.3
    done
) | gauge "Deploying" "Uploading assets to a CDN or something..."



# 12. Textbox (File Viewer)
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 12 of 21 - textbox"
textbox "Library Source" "./terminal-menus.sh"



# 13. Tailbox (Live Monitor)
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 13 of 21 - tailbox"
echo "Log initialized..." > demo.log
(sleep 1; echo "Update 1" >> demo.log; sleep 1; echo "Update 2" >> demo.log) &
tailbox "Log Monitor" "demo.log"
rm demo.log



# 14. Tree (Deep Navigation)
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 14 of 21 - tree"
TREE_DATA=(
    "0|usr|/usr|true"
    "1|bin|bin/|true"
    "2|bash|bash|false"
    "2|grep|grep|false"
    "2|sed|sed|false"
    "1|local|local/|true"
    "2|share|share/|true"
    "3|doc|doc/|true"
    "4|man|manual.txt|false"
    "1|lib|lib/|true"
    "2|python|python3/|true"
    "3|site-packages|site-packages/|true"
    "4|requests|requests/|false"
    "4|cryptography|cryptography/|false"
    "0|var|/var|true"
    "1|log|log/|true"
    "2|syslog|syslog|false"
    "2|messages|messages|false"
)

# This will return only the ID (e.g., "requests") of the chosen node
TREE_RES=$(tree "File Browser" "Select a file or directory:" 2 "${TREE_DATA[@]}")



# 15. Configtree (Complex System Configuration)
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 15 of 21 - configtree"
CONFIG_DATA=(
    "0|system|System Settings|true"
    "1|network|[x] Networking|true"
    "2|interface|Interface Type|true"
    "3|eth|(*) Ethernet|false"
    "3|wlan|( ) Wireless|false"
    "2|dhcp|[x] Use DHCP|false"
    "1|security|[ ] Security Suite|true"
    "2|firewall|[x] Enable Firewall|true"
    "3|logging|[ ] Log dropped packets|false"
    "3|stealth|[x] Stealth Mode|false"
    "2|selinux|SELinux State|true"
    "3|enforce|(*) Enforcing|false"
    "3|permiss|( ) Permissive|false"
    "0|apps|Applications|true"
    "1|web|[x] Web Server|true"
    "2|type|Server Engine|true"
    "3|nginx|(*) Nginx|false"
    "3|apache|( ) Apache|false"
    "2|ssl|[x] Enable SSL/TLS|false"
)

# This will return a list of variables like: 
# system_network_interface_eth=true
# system_network_dhcp=true
# (Note: if 'security' is unchecked, its children won't be in the output)
CONFIG_OUT=$(configtree "Advanced Config" "Configure System Components" 7 "${CONFIG_DATA[@]}")



# 16. Form (Advanced DSL)
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 16 of 21 - form"
FORM_OUT=$(form "System Provisioning" "Node: $(hostname)" \
    "> User:user=$(whoami)" \
    ">* Password:password" \
    "Enabled connections:" \
    "[ ] Ethernet:eth0" \
    "[x] Wifi:wlan0" \
    "[ ] Fibre:eth1" \
    "Deployment:" \
    "(*) Production:prod" \
    "( ) Staging:stage")

# Evaluate it to create the variables in the current shell
eval "$FORM_OUT"

# Result check
msgbox "Data Received" "
  User: $user
  Password: $password
  
  Enable connections:
  Ethernet: $eth0
  Wifi: $wlan0
  Fiber: $eth1
  
  Deployment: $deployment
"



# 17. File Navigator
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 17 of 21 - file_navigator"
FILE_PICK=$(file_navigator "Choose a file or selection" "." 2)



# 18. Table-based System Launcher
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 18 of 21 - table"
cat <<EOF > table_demo.csv
App,Version,Usage,Command
Update,2.4.1,System,echo "sudo apt update"
Clean,N/A,Disk,echo "rm -rf /tmp/*"
Logs,1.0,Monitor,tailbox "System" "/var/log/syslog"
MySQL,Stopped,3306,echo "MySQL is down"
Jenkins,Running,8080,echo "Build #42 passed"
Docker,24.0,Engine,echo "docker ps -a"
Nginx,1.24,Web,echo "nginx -t"
Redis,7.2,Cache,echo "redis-cli info"
Python,3.11,Lang,echo "python3 --version"
NodeJS,20.5,JS,echo "node -v"
Git,2.41,SCM,echo "git status"
HTOP,3.2.2,Monitor,echo "htop"
SSH,Active,Port 22,echo "who"
Postgres,15.3,DB,echo "pg_isready"
UFW,Active,FW,echo "ufw status"
Cron,Running,System,echo "crontab -l"
Grafana,10.0,Metrics,echo "systemctl status"
VSCode,1.81,Editor,echo "code --version"
TShark,4.0.7,Net,echo "tshark -D"
System,1.0,Utility,echo "uname -a"
EOF

LAUNCH_CMD=$(table "Action Center" "table_demo.csv" 3)
rm table_demo.csv
[[ -n "$LAUNCH_CMD" ]] && msgbox "Executing" "Running: $LAUNCH_CMD"



# 19. Filterable Table
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 19 of 21 - filtertable"
cat <<EOF > filter_demo.csv
App,Version,Usage,Command
Update,2.4.1,System,echo "sudo apt update"
Clean,N/A,Disk,echo "rm -rf /tmp/*"
Logs,1.0,Monitor,tailbox "System" "/var/log/syslog"
MySQL,Stopped,3306,echo "MySQL is down"
Jenkins,Running,8080,echo "Build #42 passed"
Docker,24.0.5,Engine,echo "docker ps -a"
Nginx,1.24.0,Port 80,echo "nginx -t"
Redis,7.2,Cache,echo "redis-cli info"
Python,3.11.4,Runtime,echo "python3 --version"
NodeJS,20.5.0,Runtime,echo "node -v"
Git,2.41.0,SCM,echo "git status"
HTOP,3.2.2,Monitor,echo "htop"
SSH,OpenSSH,Port 22,echo "who"
PostgreSQL,15.3,DB,echo "pg_isready"
UFW,Active,Firewall,echo "ufw status"
Cron,Running,System,echo "crontab -l"
Grafana,10.0.3,Metrics,echo "systemctl status grafana"
VSCode,1.81.0,Editor,echo "code --version"
Wireshark,4.0.7,Network,echo "tshark -D"
SystemInfo,1.0,Utility,echo "uname -a"
EOF

RESULT_CMD=$(filtertable "Real-time Service Search" "filter_demo.csv" 3)
rm filter_demo.csv
[[ -n "$RESULT_CMD" ]] && msgbox "Selection Result" "The table returned: $RESULT_CMD"




# 20. Kodi-style Main Menu (Split Pane)
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 20 of 21 - mainmenu"

CONF_FILE="app.conf"

# a helper function to write key=value pairs to a config, which removes duplicates
update_config() {
    local input="$1"
    [[ -z "$input" ]] && return

    # Ensure the config file exists so grep doesn't error
    touch "$CONF_FILE"

    # Use a while loop to handle multiline input (key=val per line)
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        # Extract the key (everything before the first =)
        local key="${line%%=*}"
        
        # 1. Remove existing entry for this specific key
        # We use a temp file to avoid "reading and writing to the same file" race conditions
        grep -v "^${key}=" "$CONF_FILE" > "${CONF_FILE}.tmp"
        
        # 2. Append the new key=val
        echo "$line" >> "${CONF_FILE}.tmp"
        
        # 3. Move it back immediately so the next iteration sees the update
        mv "${CONF_FILE}.tmp" "$CONF_FILE"
        
    done <<< "$input"
}

# Initialize empty config if it doesn't exist
: > "$CONF_FILE"

# --- 1. Movies CSV ---
{
    echo "Title,Genre,Year,Command"
    echo "The Matrix,Action,1999,echo 'Playing Matrix...'"
    for i in {1..5}; do echo "Movie $i,Genre $i,202$i,echo 'Playing Movie $i...'"; done
} > movies.csv

# --- 2. Music CSV ---
{
    echo "Artist,Album,Year,Command"
    echo "Pink Floyd,The Dark Side of the Moon,1973,echo 'Playing Pink Floyd...'"
} > music.csv

# --- 3. Settings CSV ---
# We wrap the modal call: modal "..." && echo "Key: $TUI_RESULT" >> app.conf
{
    echo "Setting,Type,Value,Command"
    echo "Profile,inputbox,Text,TUI_MODE=bottom modal \"inputbox 'Profile' 'Enter name:'\" && update_config \"profile=\$TUI_RESULT\" >> $CONF_FILE"
    echo "Resume,yesno,Choice,TUI_MODE=bottom modal \"yesno 'Playback' 'Enable Resume?'\" && update_config \"resume_enabled=\$TUI_RESULT\" >> $CONF_FILE"
    echo "Subtitles,checklist,Multi,modal \"checklist 'Lang' 'Select:' 'EN' 'ES' 'FR'\" && update_config \"subs=\$TUI_RESULT\" >> $CONF_FILE"
    echo "Resolution,radiolist,Single,modal \"radiolist 'Quality' 'Set:' '4K' '1080p' '720p'\" && update_config \"res=\$TUI_RESULT\" >> $CONF_FILE"
    echo "Credentials,form,Details,modal \"form 'Auth' 'Login' '> User:user' '>* Pass:pass'\" && update_config \"\$TUI_RESULT\" >> $CONF_FILE"
    echo "---,---,---,---"
    echo "View Config,infobox,Current State,modal \"infobox 'Saved Settings' '\$(echo ' ' && sort -u $CONF_FILE)'\""
} > settings.csv

# --- 4. DSL Orchestrator ---
KODI_MENU="Movies:Media Collection:./movies.csv
Music:Audio Library:./music.csv
Settings:System Preferences:./settings.csv"

# --- 5. Launch ---
# Note: Ensure your mainmenu logic handles the '&&' chain in the command string
mainmenu "Media Center" "Config values are saved to $CONF_FILE immediately." "$KODI_MENU" 3

# --- 6. Cleanup ---
rm movies.csv music.csv settings.csv
rm "$CONF_FILE"



# 21. An `fff` style file manager
# ------------------------------------------------------------------------------
BACKTITLE="terminal-menus.sh demo 21 of 21 - file_manager"

#TUI_MODE=centered
file_manager "File Manager Demo" "."

# 5. Capture and display the result after exiting
RESULT=$?
if [[ $RESULT -eq 0 && -n "$TUI_RESULT" ]]; then
    # Since file_manager echoes the selected file path
    clear
    echo "------------------------------------------------"
    echo "SUCCESS: File Manager returned a selection!"
    echo "Path: $TUI_RESULT"
    echo "------------------------------------------------"
elif [[ $RESULT -eq 1 ]]; then
    clear
    echo "User quit the File Manager (Pressed 'q')."
fi




# ------------------------------------------------------------------------------

# Always run this at the end, after using terminal-menus.sh
cleanup
