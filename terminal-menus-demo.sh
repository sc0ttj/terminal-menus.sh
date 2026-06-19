#!/bin/ash
# terminal-menus-demo.sh - Comprehensive Demo of the terminal-menus.sh TUI Library
#
# Usage:
#   ./terminal-menus-demo.sh              Show widget picker menu
#   ./terminal-menus-demo.sh <widget>     Run specific widget demo and exit
#   ./terminal-menus-demo.sh all          Run all demos sequentially

# Source the library
. ./terminal-menus.sh

WIDGET_LIST="All widgets
---
infobox
msgbox
yesno
inputbox
passwordbox
menu
checklist
radiolist
filtermenu
gauge
textbox
tailbox
tree
configtree
form
filepicker
table
filtertable
filemanager
spreadsheet
kanban
mainmenu"

# ==============================================================================
# Demo functions
# ==============================================================================

# 1. Info Box (Non-blocking)
demo_infobox() {
    BACKTITLE="terminal-menus.sh demo 1 of 23 - infobox"
    infobox "Welcome" "This is a demo.\n \nPlease wait 2 seconds."
    sleep 2
}

# 2. Message Box & Buttons
demo_msgbox() {
    BACKTITLE="terminal-menus.sh demo 2 of 23 - msgbox"
    OK_LABEL="Let's Go!"
    msgbox \
        "A widget with two buttons" \
        "This is a showcase of all widgets provided by this \n\`terminal-menus.sh\` library.\n \nEnjoy the show!"
}

# 3. TUI Modes (yesno)
demo_yesno_modes() {
    BACKTITLE="terminal-menus.sh demo 3 of 23 - yesno (modes)"

    MODES="centered
classic
fullscreen
popup
top
bottom
toast
palette
custom"

    _modes_c=0
    while IFS= read -r _m; do [ -n "$_m" ] && _modes_c=$((_modes_c + 1)); done <<EOF
$MODES
EOF

    current_idx=0
    OK_LABEL="Show me!"

    msgbox "MODES" "
 
You can customise the widget position and size with these different
\"modes\":
 
  centered, classic, fullscreen, popup,
  top, bottom, toast, palette, custom. 
 
You can also get different \"looks\" by enabling/disabling \$BACKTITLE.
 
You can also leave title (\$1) and msg (\$2) empty - the blank space
they leave will be automaitcally removed."

    while true; do
        TUI_MODE=$(printf "%s" "$MODES" | sed -n "$((current_idx + 1))p")
        
        YES_LABEL="Yes"; NO_LABEL="No"
        title="Choose a mode"
        msg="Current mode: $TUI_MODE.\nSee next mode?"
        BACKTITLE="terminal-menus.sh demo 3 of 23 - mode: $TUI_MODE"

        case "$TUI_MODE" in
            "popup"|"palette")
                title=""; msg="Next mode?"; BACKTITLE="yesno widget - $TUI_MODE mode" ;;
            "toast")
                title=""; msg="Next mode?"; YES_LABEL="Next mode"; NO_LABEL="Keep mode"; BACKTITLE="" ;;
            "custom")
                TUI_WIDTH=40
                TUI_HEIGHT=8
                TUI_X=25
                TUI_Y=15
                title="CUSTOM POS"
                msg="W:$TUI_WIDTH H:$TUI_HEIGHT at X:$TUI_X Y:$TUI_Y \n \nNext mode?" 
                ;;
        esac

        if [ $current_idx -eq 8 ]; then
            OK_LABEL="Let's move on.."
            TUI_MODE=classic msgbox "Thats all the modes:" "
 
centered, classic, fullscreen, popup,
top, bottom, toast, palette, custom."
            break
        else
            if yesno "$title" "$msg" 1; then
                current_idx=$(((current_idx + 1) % _modes_c))
            else
                break
            fi
        fi
    done

    unset TUI_WIDTH TUI_HEIGHT TUI_X TUI_Y
    OK_LABEL="OK"
    CANCEL_LABEL="CANCEL"
    YES_LABEL="YES"
    NO_LABEL="NO"
}

# 4. Yes/No with theme switching
demo_yesno_theming() {
    BACKTITLE="terminal-menus.sh demo 4 of 23 - yesno"
    YES_LABEL="Indeed"
    NO_LABEL="Not really"

    yesno "Theming demo" "Do you want to change UI colours?" 2
    TUI_RESULT=$?
    if [ "$TUI_RESULT" = "0" ]; then
        BG_MAIN="20;40;60"
        BG_WIDGET="40;60;80"
        HL_BLUE="0;170;170"
        _init_tui
    fi
    YES_LABEL="YES"
    NO_LABEL="No"
}

# 5. Input Box
demo_inputbox() {
    BACKTITLE="terminal-menus.sh demo 5 of 23 - inputbox"
    USER_NAME=$(inputbox "Enter you details" "Username:" "foo")
    TUI_RESULT=$USER_NAME
}

# 6. Password Box
demo_passwordbox() {
    BACKTITLE="terminal-menus.sh demo 6 of 23 - passwordbox"
    PASS=$(passwordbox "Enter you details" "password:" "ppp")
    TUI_RESULT=$PASS
}

# 7. Simple Menu
demo_menu() {
    BACKTITLE="terminal-menus.sh demo 7 of 23 - menu"
    CHOICE=$(menu "Choose an item" "Pick a fruit:" 2 "Apple" "Banana" "Cherry")
    msgbox "You chose:" "$CHOICE"
    TUI_RESULT=$CHOICE
}

# 8. Checklist
demo_checklist() {
    BACKTITLE="terminal-menus.sh demo 8 of 23 - checklist"
    CHKS=$(checklist "Choose multiple item" "Select multiple options:" 2 "Option 1" "Option 2" "Option 3")
    msgbox "You chose:" "$CHKS"
    TUI_RESULT=$CHKS
}

# 9. Radiolist
demo_radiolist() {
    BACKTITLE="terminal-menus.sh demo 9 of 23 - radiolist"
    RADIO=$(radiolist "Choose only one" "Choose exactly one:" 2 "Low" "Medium" "High")
    msgbox "You chose:" "$RADIO"
    TUI_RESULT=$RADIO
}

# 10. Filtermenu (Searchable)
demo_filtermenu() {
    BACKTITLE="terminal-menus.sh demo 10 of 23 - filtermenu"

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
    msgbox "You chose:" "$SEARCH"
    TUI_RESULT=$SEARCH
}

# 11. Gauge (Progress)
demo_gauge() {
    BACKTITLE="terminal-menus.sh demo 11 of 23 - gauge"
    (
        for i in $(seq 0 20 100); do
            echo $i
            sleep 0.5
        done
    ) | gauge "" "Uploading assets to a CDN or something..."
}

# 12. Textbox (File Viewer)
demo_textbox() {
    BACKTITLE="terminal-menus.sh demo 12 of 23 - textbox"
    textbox "" "Read file: ./terminal-menus.sh" "./terminal-menus.sh"
}

# 13. Tailbox (Live Monitor)
demo_tailbox() {
    BACKTITLE="terminal-menus.sh demo 13 of 23 - tailbox"

    if _match "$OSTYPE" "darwin*"; then
        REAL_LOG="/var/log/system.log"
    else
        REAL_LOG=/var/log/acpid.log
    fi

    tailbox "" "Monitoring file: $REAL_LOG" "$REAL_LOG"
}

# 14. Tree (Deep Navigation)
demo_tree() {
    BACKTITLE="terminal-menus.sh demo 14 of 23 - tree"
    set -- "0|usr|/usr|true" \
           "1|bin|bin/|true" \
           "2|bash|bash|false" \
           "2|grep|grep|false" \
           "2|sed|sed|false" \
           "1|local|local/|true" \
           "2|share|share/|true" \
           "3|doc|doc/|true" \
           "4|man|manual.txt|false" \
           "1|lib|lib/|true" \
           "2|python|python3/|true" \
           "3|site-packages|site-packages/|true" \
           "4|requests|requests/|false" \
           "4|cryptography|cryptography/|false" \
           "0|var|/var|true" \
           "1|log|log/|true" \
           "2|syslog|syslog|false" \
           "2|messages|messages|false"

    TREE_RES=$(ENABLE_FILTER=true tree "Choose a file from the tree" "Select a file or directory:" 2 "$@")
    msgbox "You chose" "$TREE_RES"
    TUI_RESULT=$TREE_RES
}

# 15. Configtree (Complex System Configuration)
demo_configtree() {
    BACKTITLE="terminal-menus.sh demo 15 of 23 - configtree"
    set -- "0|system|System Settings|true" \
           "1|network|[x] Networking|true" \
           "2|interface|Interface Type|true" \
           "3|eth|(*) Ethernet|false" \
           "3|wlan|( ) Wireless|false" \
           "2|dhcp|[x] Use DHCP|false" \
           "1|security|[ ] Security Suite|true" \
           "2|firewall|[x] Enable Firewall|true" \
           "3|logging|[ ] Log dropped packets|false" \
           "3|stealth|[x] Stealth Mode|false" \
           "2|selinux|SELinux State|true" \
           "3|enforce|(*) Enforcing|false" \
           "3|permiss|( ) Permissive|false" \
           "0|apps|Applications|true" \
           "1|web|[x] Web Server|true" \
           "2|type|Server Engine|true" \
           "3|nginx|(*) Nginx|false" \
           "3|apache|( ) Apache|false" \
           "2|ssl|[x] Enable SSL/TLS|false"

    CONFIG_OUT=$(ENABLE_FILTER=true configtree "Configuration tree" "Choose your desired settings" 7 "$@")
    msgbox "You chose" "$CONFIG_OUT"
    TUI_RESULT=$CONFIG_OUT
}

# 16. Form (Advanced DSL)
demo_form() {
    BACKTITLE="terminal-menus.sh demo 16 of 23 - form"
    FORM_OUT=$(form "" "" \
        "> User:user=$(whoami)" \
        ">* Password:password=pass" \
        "Country:" \
        "{ } France:france,Ireland:ireland,Thailand:thailand,Denmark:denmark,United Kingdom:uk,=USA:usa,South Africa:southafrica" \
        "Enabled connections:" \
        "[ ] Ethernet:eth0" \
        "[x] Wifi:wlan0" \
        "[ ] Fibre:eth1" \
        "Deployment:" \
        "(*) Production:prod" \
        "( ) Staging:stage")

eval "$FORM_OUT"

    msgbox "Data Received" "
  
User: $user
Password: $password
  
Country: $country
  
Enable connections:
Ethernet: $eth0
Wifi: $wlan0
Fiber: $eth1
  
Deployment: $deployment
"
    TUI_RESULT=$FORM_OUT
}

# 17. File Picker
demo_filepicker() {
    BACKTITLE="terminal-menus.sh demo 17 of 23 - filepicker"
    FILE_PICK=$(filepicker "File picker" "Choose a file" "." 5)
    [ -n "$FILE_PICK" ] && msgbox "You chose" "$FILE_PICK"
    TUI_RESULT=$FILE_PICK
}

# 18. Table-based System Launcher
demo_table() {
    BACKTITLE="terminal-menus.sh demo 18 of 23 - table"
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

    LAUNCH_CMD=$(table "Table" "Pick an item" "table_demo.csv" 3)
    rm table_demo.csv
    [ -n "$LAUNCH_CMD" ] && msgbox "" "You chose: $LAUNCH_CMD"
    TUI_RESULT=$LAUNCH_CMD
}

# 19. Filterable Table
demo_filtertable() {
    BACKTITLE="terminal-menus.sh demo 19 of 23 - filtertable"
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

    RESULT_CMD=$(filtertable "Filterable table" "Type to search, pick an item." "filter_demo.csv" 3)
    rm filter_demo.csv
    [ -n "$RESULT_CMD" ] && msgbox "Selection Result" "The table returned: $RESULT_CMD"
    TUI_RESULT=$RESULT_CMD
}

# 20. An `fff` style file manager
demo_filemanager() {
    BACKTITLE="terminal-menus.sh demo 20 of 23 - filemanager"

    # Use external preview script instead of the built-in one
    . ./preview.sh

    # Custom keybindings demonstrating modal popups via TUI_EXTRA_KEYS
    TUI_EXTRA_KEYS="
shift_u=modal \"msgbox 'Help' 'Navigate with arrows/j/k.\nTab to select files.\nq to quit.\n \nExtra keys:\n  ? - This help\n  @ - System info\n  o - About TUI_EXTRA_KEYS'\"
2=modal \"infobox 'System Info' 'terminal-menus.sh v1.0\nBusyBox Ash + Bash compatible\nZero dependencies\n \nTUI_EXTRA_KEYS lets you add\ncustom modal keybindings!'\"
3=modal \"msgbox 'About TUI_EXTRA_KEYS' 'Set TUI_EXTRA_KEYS env var with:\n  key=modal \\\"widget args\\\"\n  ctrl_x=modal \\\"info …\\\"\n \nKeys are checked before the\nwidgets native handlers.'\"
"
    export TUI_EXTRA_KEYS

    filemanager "Advanced file manager" "." 5

    RESULT=$?
    if [ $RESULT -eq 0 ] && [ -n "$TUI_RESULT" ]; then
        msgbox "You chose:" "$TUI_RESULT"
    elif [ $RESULT -eq 1 ]; then
        msgbox "You quit the File Manager (Pressed 'q')."
    fi

    TUI_EXTRA_KEYS=""
    export TUI_EXTRA_KEYS
}

# 21. Interactive Spreadsheet
demo_spreadsheet() {
    BACKTITLE="terminal-menus.sh demo 21 of 23 - spreadsheet"

    cat <<EOF > budget.csv
Category,Amount,Notes
Groceries,150.00,Weekly shop
Rent,1200.00,Monthly
Internet,60.00,Fiber
Savings,200.00,Auto-transfer
Misc,45.50,Buffer
EOF

    FINAL_DATA=$(spreadsheet "Spreadsheet editor" "budget.csv"); SS_EXIT=$?

    if [ $SS_EXIT -eq 0 ]; then
        SUMMARY=$(echo "$FINAL_DATA" | head -n 8)
        msgbox "Spreadsheet Saved" "Data returned to script successfully.\n\nPreview:\n$SUMMARY\n..."
    else
        msgbox "Spreadsheet" "Changes discarded."
    fi

    TUI_RESULT=$FINAL_DATA

    rm budget.csv
}

# 22. Kanban board with search
demo_kanban() {
    BACKTITLE="terminal-menus.sh demo 22 of 23 - kanban"

    cleanup

    mkdir -p ~/my_project
    echo "Backlog,In Progress,Testing,Done" > ~/my_project/.project-config

    NOW=$(date +"%Y-%m-%d-%H:%M:%S")

    cat <<EOF > ~/my_project/api_rate_limiting.md
title: Implement API rate limiting
status: Backlog
created: $NOW
modified: $NOW
completed:
rank: 10
author: $(whoami)
owner: $(whoami)
tags: @feature +backend +security
---
Add token-bucket rate limiting to all public API endpoints.
EOF

    cat <<EOF > ~/my_project/login_oauth.md
title: Add OAuth2 login support
status: In Progress
created: $(date -d "3 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
modified: $NOW
completed:
rank: 40
author: $(whoami)
owner: $(whoami)
tags: @feature +auth +frontend
---
Integrate Google and GitHub OAuth2 providers. Wire up the callback flow and JWT session tokens.
EOF

    cat <<EOF > ~/my_project/ci_pipeline.md
title: Set up CI/CD pipeline
status: In Progress
created: $(date -d "5 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
modified: $NOW
completed:
rank: 50
author: $(whoami)
owner: $(whoami)
tags: @ops +infra
---
Configure GitHub Actions for lint, test, build, and deploy to staging.
EOF

    cat <<EOF > ~/my_project/search_index_fix.md
title: Fix search index corruption bug
status: Testing
created: $(date -d "7 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
modified: $(date -d "1 day ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
completed:
rank: 80
author: $(whoami)
owner: $(whoami)
tags: @bug +search +backend
---
Rare race condition corrupts the inverted index under concurrent writes. Fix applied, needs QA sign-off.
EOF

    cat <<EOF > ~/my_project/db_migration.md
title: Migrate database to PostgreSQL
status: Done
created: $(date -d "14 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
modified: $(date -d "2 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
completed: $(date -d "2 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
rank: 95
author: $(whoami)
owner: $(whoami)
tags: @ops +database
---
Migrated from SQLite to PostgreSQL 16 with zero-downtime replication. All data verified.
EOF

    cat <<EOF > ~/my_project/readme_update.md
title: Update project README
status: Backlog
created: $NOW
modified: $NOW
completed:
rank: 20
author: $(whoami)
owner: $(whoami)
tags: @docs +meta
---
Document the new API endpoints, setup instructions, and contribution guide.
EOF

    TUI_MODE=fullscreen kanban "Project" "Manage your tickets and notes" ~/my_project
    TUI_RESULT=$?

    rm -rf ~/my_project
}

# 23. Kodi-style Main Menu (Split Pane)
demo_mainmenu() {
    BACKTITLE="terminal-menus.sh demo 23 of 23 - mainmenu"

    CONF_FILE="app.conf"

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

    : > "$CONF_FILE"

    {
        echo "Title,Genre,Year,Command"
        echo "The Matrix,Action,1999,echo 'Playing Matrix...'"
        for i in $(seq 1 5); do echo "Movie $i,Genre $i,202$i,echo 'Playing Movie $i...'"; done
    } > movies.csv

    {
        echo "Artist,Album,Year,Command"
        echo "Pink Floyd,The Dark Side of the Moon,1973,echo 'Playing Pink Floyd...'"
    } > music.csv

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
    } > settings.csv

    KODI_MENU="Movies:my mooovies:./movies.csv
Music:tuuuunes:./music.csv
Settings:settings:./settings.csv"

    TUI_PERSISTENT_FILTERS=true mainmenu "Media center" "" "$KODI_MENU" 3
    RESULT=$?
    if [ $RESULT -eq 0 ] && [ -n "$TUI_RESULT" ]; then
        msgbox "TUI_RESULT (last command you ran)" "$TUI_RESULT"
        msgbox "Your CONF_FILE:" "$(cat $CONF_FILE)"
    fi

    rm movies.csv music.csv settings.csv "$CONF_FILE"
}

# ==============================================================================
# Dispatch (used when sourcing the script)
# ==============================================================================

demo_yesno() {
    demo_yesno_modes
    demo_yesno_theming
}

run_all() {
    demo_infobox
    demo_msgbox
    demo_yesno_modes
    demo_yesno_theming
    demo_inputbox
    demo_passwordbox
    demo_menu
    demo_checklist
    demo_radiolist
    demo_filtermenu
    demo_gauge
    demo_textbox
    demo_tailbox
    demo_tree
    demo_configtree
    demo_form
    demo_filepicker
    demo_table
    demo_filtertable
    demo_filemanager
    demo_spreadsheet
    demo_kanban
    demo_mainmenu
}

run_widget() {
    case "$1" in
        "yesno")
            demo_yesno_modes
            demo_yesno_theming
            ;;
        "infobox")     demo_infobox ;;
        "msgbox")      demo_msgbox ;;
        "inputbox")    demo_inputbox ;;
        "passwordbox") demo_passwordbox ;;
        "menu")        demo_menu ;;
        "checklist")   demo_checklist ;;
        "radiolist")   demo_radiolist ;;
        "filtermenu")  demo_filtermenu ;;
        "gauge")       demo_gauge ;;
        "textbox")     demo_textbox ;;
        "tailbox")     demo_tailbox ;;
        "tree")        demo_tree ;;
        "configtree")  demo_configtree ;;
        "form")        demo_form ;;
        "filepicker")  demo_filepicker ;;
        "table")       demo_table ;;
        "filtertable") demo_filtertable ;;
        "filemanager") demo_filemanager ;;
        "spreadsheet") demo_spreadsheet ;;
        "kanban")      demo_kanban ;;
        "mainmenu")    demo_mainmenu ;;
        *)
            echo "Unknown widget: $1"
            echo "Valid: all, infobox, msgbox, yesno, inputbox, passwordbox, menu, checklist,"
            echo "       radiolist, filtermenu, gauge, textbox, tailbox, tree, configtree,"
            echo "       form, filepicker, table, filtertable, filemanager, spreadsheet,"
            echo "       kanban, mainmenu"
            exit 1
            ;;
    esac
}

# ==============================================================================
# Main
# ==============================================================================

case "$0" in *terminal-menus-demo.sh)
    case "${1:-}" in
        "")
            while true; do
                choice=$(filtermenu "Choose a widget" "Widget:" 12 "$WIDGET_LIST")
                [ -z "$choice" ] && break
                if [ "$choice" = "All widgets" ]; then
                    run_all
                    break
                fi
                run_widget "$choice"
            done
            ;;
        "all")
            run_all
            ;;
        *)
            run_widget "$1"
            ;;
    esac
    cleanup
esac