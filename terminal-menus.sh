#!/bin/bash

# Copyright (c) 2026 sc0ttj
# Licensed under the MIT License
# https://opensource.org

# --- UI colours ---

: ${BG_MAIN:="34;34;34"}            # Dark grey main background
: ${BG_MODAL:="50;50;50"}           # Lighter grey for modal popups
: ${BG_WIDGET:="68;68;68"}          # Standard button/widget background
: ${FG_TEXT:="239;239;239"}         # Off-white primary text
: ${BG_ACTIVE:="60;120;160"}        # Unified deep blue focus color
: ${HL_BLUE:="$BG_ACTIVE"}          # Map highlight blue to active focus
: ${FG_HINT:="150;150;150"}         # Dimmed grey for control hints
: ${FG_BACKTITLE:="95;175;215"}     # Light blue for desktop background text
: ${BG_INPUT:="20;20;20"}           # Near black for input backgrounds
: ${FG_INPUT:="95;175;215"}         # Light blue for active input text
: ${FG_INPUT_ROOT:="255;60;60"}     # Red for Root prompt

# : ${FG_BLUE_BOLD:="\e[1;38;2;${FG_INPUT}m"}
# : ${HL_WHITE_BOLD:="\e[48;2;${BG_ACTIVE}m\e[38;2;255;255;255;1m"}

# --- ANSI helpers ---
 
RESET="\e[0m"    # Reset all formatting and colours
BOLD="\e[1m"     # Set text to bold weight
CLR_EOL="\e[K"   # Clear line from cursor to right edge
CLR_DOWN="\e[J"  # Clear screen from cursor to bottom
FAINT="${ESC}[2m"

_esc() { echo -ne "\e[${1};2;${2}m"; }

# --- UI Labels ---

# Optional title that goes at the very top
: ${BACKTITLE:=""}

# --- Global Button Labels ---
: ${OK_LABEL:="OK"}
: ${CANCEL_LABEL:="CANCEL"}
: ${YES_LABEL:="YES"}
: ${NO_LABEL:="NO"}


# --- GLOBAL LAYOUT INITIALISATION ---
# This runs once when the script starts
_TERM_W=$(tput cols)
_TERM_H=$(tput lines)

# Safety Clamping
[[ $MAX_WIDTH -gt $_TERM_W ]] && MAX_WIDTH=$_TERM_W && PADDING_LEFT=0
[[ $MAX_HEIGHT -gt $_TERM_H ]] && MAX_HEIGHT=$_TERM_H && PADDING_TOP=0

# a var that always captures the output of a widget
TUI_RESULT=""

LAST_FRAME=""

# --- Setup ---

cleanup() {
    # 1. Send ANSI Escape Sequences to the terminal
    # \e[?25h  -> Show Cursor: Reverses \e[?25l (which hides it during UI drawing)
    # \e[?1000l -> Disable Mouse: Stops the terminal from sending click/scroll events as text
    # \e[0m     -> Reset Colors: Clears all TrueColor/Bold styles and returns to default
    # \e[H      -> Cursor Home: Moves the cursor to the top-left (1,1)
    # \e[J      -> Clear Screen: Wipes everything from the cursor (Home) to the bottom
    # >&2       -> Redirect to STDERR: Ensures these UI codes don't corrupt piped data output
    printf "\e[?25h\e[?1000l\e[0m\e[H\e[J" >&2

    # 2. Reset the terminal line settings
    # sane     -> Restores keyboard 'echo' and standard input buffering. 
    #             Critical if the script crashed while 'stty -echo' was active.
    stty sane

    # 3. Terminfo-based cursor restoration
    # cnorm    -> "Cursor Normal". A portable backup command to ensure the 
    #             cursor is visible even on non-XTerm compatible terminals.
    tput cnorm
}

# trap         -> The Bash built-in command used to catch signals or events.
# cleanup      -> The name of the function to execute when the event occurs.
# EXIT         -> A special Bash "pseudo-signal" that triggers when the shell 
#                 process ends for ANY reason (normal finish, error, or exit command).
#
# Combined: This ensures the terminal is restored (via cleanup) even if the 
#           script crashes or the user exits unexpectedly, preventing a 
#           permanently "broken" terminal state.
trap cleanup EXIT

# Define a function to refresh the TUI on resize
handle_resize() {
    # Most widgets call _init_tui at the start of their loop.
    # By triggering a "continue" in your widget loops or 
    # simply re-calculating dimensions, the UI will "snap" to the new center.
    _init_tui
}

# Trap the WINCH (Window Change) signal
trap handle_resize SIGWINCH

# --- Helper functions ---

_show_cursor() { printf "\e[?25h" >&2; }
_hide_cursor() { printf "\e[?25l" >&2; }

# Define these ONCE at the top level of your script (outside _init_tui)
# to avoid re-calculating strings that never change.
_init_static_colors() {
    # We remove the gate so this can be re-run during theme switches.
    # Map HL_BLUE to BG_ACTIVE to ensure highlights update
    BG_ACTIVE="${HL_BLUE:-$BG_ACTIVE}"
    
    BG_MAIN_ESC="\e[48;2;${BG_MAIN}m"
    BG_MODAL_ESC="\e[48;2;${BG_MODAL}m"
    FG_TEXT_ESC="\e[38;2;${FG_TEXT}m"
    FG_HINT_ESC="\e[22m\e[38;2;${FG_HINT}m"
    BG_ACTIVE_ESC="\e[48;2;${BG_ACTIVE}m"
    BG_BLUE_ESC="$BG_ACTIVE_ESC"
    BG_WID_ESC="\e[48;2;${BG_WIDGET}m"
    BG_WID_TEXT_ESC="${BG_WID_ESC}${FG_TEXT_ESC}"
    FG_INPUT_ESC="\e[38;2;${FG_INPUT}m"
    BG_INPUT_ESC="\e[48;2;${BG_INPUT}m"
    FG_BACKTITLE_ESC="\e[38;2;${FG_BACKTITLE}m"
    BG_TABLE_HEADER_ESC="\e[48;2;100;100;100m${FG_TEXT_ESC}"
    
    # Pre-calculate bolds based on the current active/highlight colors
    FG_BLUE_BOLD="\e[1;38;2;${FG_INPUT}m"
    HL_WHITE_BOLD="\e[48;2;${BG_ACTIVE}m\e[38;2;255;255;255;1m"
}

_init_tui() {
    stty -echo
    _apply_layout
    
    # ALWAYS re-init colors to support theme switching
    _init_static_colors

    # 1. FLICKER-FREE BACKGROUND HANDLING
    if [[ "$TUI_MODAL" == "true" ]]; then
        printf "\e[H\e[2m%b\e[0m" "$LAST_FRAME" >&2
    else
        printf "\e[0m\e[H\e[2J\e[3J" >&2
    fi

    # 2. RE-BUILD THE WALL (Now with the new theme colors)
    local wall="" line_fill=""
    printf -v line_fill "%*s" "$MAX_WIDTH" ""
    
    for ((i=0; i<MAX_HEIGHT; i++)); do
        local r=$((PADDING_TOP + i + 1))
        # This will now use the updated BG_MAIN_ESC
        wall+="\e[${r};${PADDING_LEFT}H${BG_MAIN_ESC}${line_fill}"
    done
    printf "%b\e[0m" "$wall" >&2

    # 3. BACKTITLE
    if [[ -n "$BACKTITLE" ]]; then
        local title_row=$(( PADDING_TOP ))
        [[ $title_row -lt 1 ]] && title_row=1
        local clr=""
        [[ "$TUI_MODAL" != "true" ]] && clr="\e[K"
        printf "\e[${title_row};${PADDING_LEFT}H\e[0m${FG_BACKTITLE_ESC}${BOLD}%s${clr}\e[0m" "$BACKTITLE" >&2
    fi

    # 4. PARK CURSOR
    printf "\e[1;1H\e[?25l" >&2

    # Reset global row for the next widget
    if [[ -n "$BACKTITLE" && $PADDING_TOP -eq 0 ]]; then
        row=3
    else
        row=2
    fi
}

_draw_background_widget_faint() {
    # We force the FAINT code and tell the widget to draw
    # This requires the widget to support a 'no-clear' mode
    printf "${FAINT}" >&2
    # Call your last background render logic here
    # (This is why keeping state in variables like you did is so important!)
}

# --- GLOBAL LAYOUT INITIALISATION ---
# Run once at startup to set initial state
_TERM_W=$(tput cols)
_TERM_H=$(tput lines)

_apply_layout() {
    # Use local variables for the current terminal state to support resizing
    local term_w=$(tput cols)
    local term_h=$(tput lines)
    local mode="${TUI_MODE:-centered}"

    case "$mode" in
        "fullscreen")
            MAX_WIDTH=$term_w;   MAX_HEIGHT=$term_h
            PADDING_LEFT=0;       PADDING_TOP=0
            ;;
        "popup")
            MAX_WIDTH=50;         MAX_HEIGHT=7
            PADDING_LEFT=$(( (term_w - MAX_WIDTH) / 2 ))
            PADDING_TOP=$(( (term_h - 10) / 2 ))
            ;;
        "top")
            MAX_WIDTH=$term_w;   MAX_HEIGHT=10
            PADDING_LEFT=0;       PADDING_TOP=0
            ;;
        "bottom")
            MAX_WIDTH=$term_w;   MAX_HEIGHT=10
            PADDING_LEFT=0;       PADDING_TOP=$(( term_h - MAX_HEIGHT ))
            ;;
        "toast")
            MAX_WIDTH=${TOAST_WIDTH:-35}
            MAX_HEIGHT=${TOAST_HEIGHT:-4}
            PADDING_TOP=1
            PADDING_LEFT=$(( term_w - MAX_WIDTH - 2 ))
            ;;
        "palette")
            MAX_WIDTH=${PALETTE_WIDTH:-32}
            MAX_HEIGHT=${PALETTE_HEIGHT:-10}
            local anchor=${ANCHOR:-"br"}
            # Vertical Anchor
            case "${anchor:0:1}" in
                "t") PADDING_TOP=1 ;;
                "b") PADDING_TOP=$(( term_h - MAX_HEIGHT - 1 )) ;;
                "c"|*) PADDING_TOP=$(( (term_h - MAX_HEIGHT) / 2 )) ;;
            esac
            # Horizontal Anchor
            case "${anchor:1:1}" in
                "l") PADDING_LEFT=2 ;;
                "r") PADDING_LEFT=$(( term_w - MAX_WIDTH - 2 )) ;;
                "c"|*) PADDING_LEFT=$(( (term_w - MAX_WIDTH) / 2 )) ;;
            esac
            ;;
        "classic")
            MAX_WIDTH=80;         MAX_HEIGHT=25
            PADDING_LEFT=$(( (term_w - MAX_WIDTH) / 2 ))
            PADDING_TOP=$(( (term_h - MAX_HEIGHT) / 2 ))
            ;;
        "centered"|*)
            MAX_WIDTH=75;         MAX_HEIGHT=22
            PADDING_LEFT=$(( (term_w - MAX_WIDTH) / 2 ))
            PADDING_TOP=$(( (term_h - MAX_HEIGHT) / 2 ))
            ;;
    esac

    # Safety Clamping (Ensures UI never draws off-screen)
    [[ $MAX_WIDTH -gt $term_w ]] && MAX_WIDTH=$term_w && PADDING_LEFT=0
    [[ $MAX_HEIGHT -gt $term_h ]] && MAX_HEIGHT=$term_h && PADDING_TOP=0
}

# Initial call to set global variables based on default mode
_apply_layout

_get_start_row() {
    # If we have a backtitle AND we are at the very top of the screen (Full Screen)
    # we need to push the content down to Row 4 to leave 2 empty lines.
    if [[ -n "$BACKTITLE" && $PADDING_TOP -eq 0 ]]; then
        echo 3
    else
        # In centered-box mode, the title is OUTSIDE the box, 
        # so we only need a 1-line margin INSIDE the box.
        echo 2
    fi
}

_draw_at() {
    # target_col = (Padding) + (Relative Col)
    # Using local -i (integer) in 3.2 is slightly faster for math
    local -i target_row=$(( $1 + PADDING_TOP ))
    local -i target_col=$(( PADDING_LEFT + ${2:-${COL_START:-0}} ))

    printf "\e[%d;%dH${BG_MAIN_ESC}" "$target_row" "$target_col" >&2
}

_draw_clear_line() {
    # Combine the move and the clear into ONE printf call
    local -i target_row=$(( row + PADDING_TOP ))
    local -i target_col=$(( PADDING_LEFT + ${COL_START:-0} ))
    printf "\e[%d;%dH${BG_MAIN_ESC}%*s" "$target_row" "$target_col" "$MAX_WIDTH" "" >&2
}

_draw_line() {
    [[ -n "$2" ]] && row=$2
    local -i target_row=$(( row + PADDING_TOP ))
    local -i target_col=$(( PADDING_LEFT + ${COL_START:-0} ))
    
    # Combined: Move + Background Color + Text + Newline Logic
    # This removes the separate call to _draw_at
    printf "\e[%d;%dH${BG_MAIN_ESC}%b" "$target_row" "$target_col" "$1" >&2
    ((row++))
}

_draw_spacer() { ((row++)); }

_draw_header() {
    local title=$1 msg=$2
    
    # --- FIX 1: Remove subshell from _get_start_row ---
    if [[ -n "$BACKTITLE" && $PADDING_TOP -eq 0 ]]; then
        row=3
    else
        row=2
    fi
    
    # 1. Title Row - Built with %b for immediate speed
    _draw_line "  ${FG_TEXT_ESC}=== $title ===${RESET}${BG_MAIN_ESC}"
    
    # 2. Convert literal "\n" into real newlines without a subshell
    local expanded_msg
    printf -v expanded_msg "%b" "$msg"

    # 3. Render each line individually
    local old_ifs="$IFS"
    IFS=$'\n' # Standard Bash 3.2 newline variable
    for line in $expanded_msg; do
        # Directly calculate coordinates to avoid calling _draw_at in a loop
        local -i target_row=$(( row + PADDING_TOP ))
        local -i target_col=$(( PADDING_LEFT + ${COL_START:-0} ))
        
        # Combine Move + Padding + Text into one atomic I/O operation
        printf "\e[%d;%dH${BG_MAIN_ESC}  %s" "$target_row" "$target_col" "$line" >&2
        
        # Increment row and draw the trailing background snap
        _draw_line ""
    done
    IFS="$old_ifs"
    
    _draw_line ""
}

_draw_controls() {
    local hints=$1
    # We use _draw_line to ensure the background fills the MAX_WIDTH 
    # and respects PADDING_LEFT
    _draw_line " ${FG_HINT_ESC}${hints}${RESET}${BG_MAIN_ESC}"
}

_draw_footer() {
    # Instead of clearing the whole terminal, we just clear the 
    # remaining lines inside the MAX_HEIGHT boundary.
    local current_row=$row
    while [[ $current_row -lt $MAX_HEIGHT ]]; do
        _draw_at "$current_row"
        printf "%*s" "$MAX_WIDTH" "" >&2
        ((current_row++))
    done
}

_draw_btn() {
    local label=$1 is_active=$2
    
    if [[ $is_active -eq 1 ]]; then
        # Active: Blue BG + Bold
        printf "${BG_BLUE_ESC}${BOLD} $label ${RESET}${BG_MAIN_ESC}" >&2
    else
        # Inactive: Widget Grey
        printf "${BG_WID_ESC} $label ${RESET}${BG_MAIN_ESC}" >&2
    fi
}

_draw_item() {
    local type=$1 is_cur=$2 is_sel=$3 content=$4 width=${5:-30}
    local style px=""

    case "$type" in
        "check") [[ $is_sel -eq 1 ]] && px="[x] " || px="[ ] " ;;
        "radio") [[ $is_sel -eq 1 ]] && px="(*) " || px="( ) " ;;
        *) px="" ;;
    esac

    [[ $is_cur -eq 1 ]] && style="${HL_WHITE_BOLD}" || style="${BG_WID_ESC}${FG_TEXT_ESC}"

    # We use %-s to force the background style to exactly 'width' characters.
    # We strip any trailing spaces from content to prevent overflow.
    printf "${style} %-${width}s ${RESET}${BG_MAIN_ESC}" "${px}${content}" >&2

}

_draw_form_field() {
    local label=$1 value=$2 is_active=$3 i=$4 width=$5 col_start=$6
    
    # This local variable overrides the global one for this function call
    local COL_START=$col_start
    
    # Ensure all your _draw_at calls in here now land on the centered column
    # Example for labels:
    _draw_at "$row"
    local style="" content=""

    # --- 1. INPUT & PASSWORD ---
    if [[ "$label" == ">"* ]]; then
        local box_w=$(( width - 10 ))
        local clean_lbl="${label#> }"; clean_lbl="${clean_lbl#* }"
        local prompt=" > "
        
        style=$([[ $is_active -eq 1 ]] && echo "${FG_BLUE_BOLD}" || echo "${FG_TEXT_ESC}")
        _draw_line "  ${style}${clean_lbl}:${RESET}${BG_MAIN_ESC}"

        local display_val="$value"
        local suffix=""
        
        # USE THE PASSED WIDTH instead of hardcoded 38/34
        # Subtract 6 to account for the " > " prompt and padding
        local box_w=$(( width - 6 ))
        
        if [[ "$label" == ">*"* ]]; then
            display_val=$(printf '%*s' "${#value}" '' | tr ' ' '*')
            suffix=" 🔑 "
            box_w=$(( box_w - 4 )) # Make room for the key icon
        fi

        style=$([[ $is_active -eq 1 ]] && echo "${BG_INPUT_ESC}${FG_BLUE_BOLD}" || echo "${BG_WID_ESC}${FG_TEXT_ESC}")
        
        _draw_at "$row"
        printf "  ${style}${prompt}%-${box_w}s${suffix}${RESET}${BG_MAIN_ESC}" "$display_val" >&2
        ((row++))
        _draw_spacer

    # --- 2. STANDALONE CHECKBOX OR RADIO ---
    elif [[ "$label" == "[ ]"* || "$label" == "("* ]]; then
        local marker="" indent="  "
        # Logic for style selection remains the same
        style=$([[ $is_active -eq 1 ]] && echo "${HL_WHITE_BOLD}" || echo "${BG_MAIN_ESC}${FG_TEXT_ESC}")
        
        if [[ "$label" == "[ ]"* ]]; then
            content="${label#\[ \] }"
            marker=$([[ "$value" == "1" ]] && echo "[x] " || echo "[ ] ")
        else
            content="${label/( ) /}"
            marker=$([[ "$value" == "1" ]] && echo "(*) " || echo "( ) ")
        fi
        indent="  "

        # _draw_line handles the MAX_WIDTH padding
        _draw_line "${indent}${style}${marker}${content}${RESET}${BG_MAIN_ESC}"
        
        # --- THE SURGICAL FIX ---
        # Only draw a spacer if the NEXT field (i+1) is NOT a checkbox
        # This prevents the "empty line" bug in lists of checkboxes
        local next_idx=$((i + 1))
        if [[ "$label" == "[ ]"* && "${fields[$next_idx]}" != "[ ]"* ]]; then
            _draw_spacer
        fi

    # --- 3. DROPDOWNS ---
    elif [[ "$label" == "{"* ]]; then
        IFS='|' read -r state sel_idx query opt_str <<< "$value"
        IFS=',' read -r -a all_opts <<< "$opt_str"
        
        local filtered=()
        local l_query=$(echo "$query" | tr '[:upper:]' '[:lower:]')
        for o in "${all_opts[@]}"; do
            local l_opt=$(echo "$o" | tr '[:upper:]' '[:lower:]')
            [[ -z "$query" || "$l_opt" == *"$l_query"* ]] && filtered+=("$o")
        done

        local arrow=$([[ "$state" == "OPEN" ]] && echo "▴" || echo "▾")
        local header="${label#\{*\} }: "
        [[ "$label" == "{>}"* && "$state" == "OPEN" ]] && header+="[ $query ] $arrow" || header+="${all_opts[$sel_idx]} $arrow"
        
        style=$([[ $is_active -eq 1 ]] && echo "${FG_BLUE_BOLD}" || echo "${FG_TEXT_ESC}")
        _draw_line "  ${style}${header}${RESET}${BG_MAIN_ESC}"

        if [[ "$state" == "OPEN" ]]; then
            for ((j=0; j<${#filtered[@]}; j++)); do
                _draw_at "$row"; printf "  " >&2 
                # _draw_item was fixed to use fixed width, so it won't bleed out
                _draw_item "menu" "$([[ $j -eq $sel_idx ]] && echo 1 || echo 0)" 0 "${filtered[$j]}" 44
                ((row++))
            done
        fi
        _draw_spacer

    # --- 4. STATIC LABEL ---
    else
        _draw_line "  $label"
    fi
}

_draw_list() {
    local type=$1 title=$2 msg=$3 def_idx=$4; shift 4
    local options=("$@") count=${#options[@]} cur=$def_idx
    local selected=(); for ((i=0; i<count; i++)); do selected[i]=0; done
    local width=30 

    _init_tui
    while true; do
        _draw_header "$title" "$msg"
        
        local list_top=$row
        for ((i=0; i<count; i++)); do
            _draw_at "$((list_top + i))"
            printf "  " >&2 
            local is_cur=0; [[ $i -eq $cur ]] && is_cur=1
            _draw_item "$type" "$is_cur" "${selected[i]}" "${options[i]}" "$width"
            _draw_line "" "$((list_top + i))"
        done
        
        row=$((list_top + count))
        local hint=" [Arrows] Move | [Space] Toggle | [Enter] Select"
        [[ $type == "menu" ]] && hint=" [Arrows] Move | [Enter] Select"
        
        ((row++))
        _draw_controls "$hint"
        _draw_footer

        # --- FIXED INPUT HANDLING ---
        local key
        IFS= read -rsn1 key < /dev/tty
        
        if [[ "$key" == $'\e' ]]; then 
            # Read the next 2 chars (e.g., [A) from TTY
            read -rsn2 key < /dev/tty
            case "$key" in
                "[A") [[ $cur -gt 0 ]] && ((cur--)) ;;
                "[B") [[ $cur -lt $((count-1)) ]] && ((cur++)) ;;
                "<0"|"<3") 
                    # Mouse reads must also point to TTY
                    read -d ';' -r m_btn < /dev/tty
                    read -d ';' -r m_col < /dev/tty
                    read -r m_last < /dev/tty
                    local m_row=${m_last%[mM]}
                    local idx=$((m_row - list_top - PADDING_TOP))
                    if [[ $idx -ge 0 && $idx -lt $count ]]; then
                        cur=$idx
                        [[ $m_last == *M ]] && { 
                            if [[ $type == "menu" ]]; then 
                                TUI_RESULT="${options[cur]}"; return
                            else 
                                key=" "; 
                            fi
                        }
                    fi
                    ;;
            esac
            # Special check to prevent Escape from triggering the Space logic
            [[ $key != " " ]] && continue
        fi
        
        if [[ "$key" == " " ]]; then
            if [[ $type == "check" ]]; then
                selected[cur]=$((1 - selected[cur]))
            elif [[ $type == "radio" ]]; then
                for ((j=0; j<count; j++)); do selected[j]=0; done; selected[cur]=1
            fi
        elif [[ -z "$key" ]]; then
            if [[ $type == "menu" ]]; then 
                # Assign to global TUI_RESULT for modal support
                TUI_RESULT="${options[cur]}"; return
            else 
                local res=""
                for ((i=0; i<count; i++)); do [[ ${selected[i]} -eq 1 ]] && res+="${options[i]} "; done
                TUI_RESULT="${res% }"; return
            fi
        fi
    done
}

# --- Widgets ---

menu() {
    local t=$1 m=$2 d=0
    if [[ "$3" =~ ^[0-9]+$ ]]; then
        d=$(( $3 - 1 ))
        shift 3
    else
        shift 2
    fi
    _draw_list "menu" "$t" "$m" "$d" "$@"
}

checklist() {
    local t=$1 m=$2 d=0
    if [[ "$3" =~ ^[0-9]+$ ]]; then
        d=$(( $3 - 1 ))
        shift 3
    else
        shift 2
    fi
    _draw_list "check" "$t" "$m" "$d" "$@"
}

radiolist() {
    local t=$1 m=$2 d=0
    if [[ "$3" =~ ^[0-9]+$ ]]; then
        d=$(( $3 - 1 ))
        shift 3
    else
        shift 2
    fi
    _draw_list "radio" "$t" "$m" "$d" "$@"
}

msgbox() {
    local title=$1 msg=$2
    _init_tui
    while true; do
        _draw_header "$title" "$msg"
        
        # Draw a spacer line
        #_draw_spacer # this causes the button to be one line to far down, disable it
        
        # We use _draw_at to place the button exactly where we want it
        # then we use _draw_line to "finish" the background for that row
        _draw_at "$row"
        printf "  " >&2 # Indent the button 2 spaces
        _draw_btn "$OK_LABEL" 1
        
        # Now call _draw_line with an empty string to "close" the background bar
        _draw_line ""
        
        _draw_footer
        
        IFS= read -rsn1 key < /dev/tty
        [[ -z $key ]] && return 0
    done
}

yesno() {
    # FIX 1: Set default to 0 (Yes) and ensure it's a valid index
    # We use ${3:-1} so that passing 1 focuses 'Yes' and 2 focuses 'No'
    local title=$1 msg=$2 cur
    cur=$(( ${3:-1} - 1 ))
    
    _init_tui
    while true; do
        _draw_header "$title" "$msg"
        
        # 1. Position cursor for the button row
        _draw_at "$row"
        
        # 2. Render buttons with binary focus check
        printf "  " >&2
        # Use simple numeric comparison
        if (( cur == 0 )); then _draw_btn "$YES_LABEL" 1; else _draw_btn "$YES_LABEL" 0; fi
        printf "  " >&2
        if (( cur == 1 )); then _draw_btn "$NO_LABEL" 1; else _draw_btn "$NO_LABEL" 0; fi
        
        # 3. Snap the background and footer
        _draw_line "" "$row"
        _draw_footer

        # FIX 2: All parts of the escape sequence must read from /dev/tty
        local key; IFS= read -rsn1 key < /dev/tty
        
        if [[ $key == $'\e' ]]; then
            # We must redirect this read to /dev/tty too!
            read -rsn2 key < /dev/tty
            # [C is Right, [D is Left
            if [[ $key == "[C" || $key == "[D" ]]; then
                cur=$(( 1 - cur ))
            fi
            continue
        fi
        
        # Enter key returns the current index
        if [[ -z $key ]];then
            [[ $cur == 0 ]] && TUI_RESULT=true
            [[ $cur == 1 ]] && TUI_RESULT=false
            return $cur
        fi
    done
}

inputbox() {
    local title=$1 msg=$2 val="${3:-}" char key
    local pos=${#val}
    _init_tui
    _draw_header "$title" "$msg"

    local input_row=$row
    local phys_row=$((input_row + PADDING_TOP))

    while true; do
        _hide_cursor
        _draw_at "$input_row"
        printf "  ${BG_INPUT_ESC}${FG_INPUT_ESC} > %-34s ${RESET}${BG_MAIN_ESC}" "$val" >&2
        printf "\e[${phys_row};$((PADDING_LEFT + 5 + pos))H" >&2
        _show_cursor

        # Read the first character
        IFS= read -rsn1 char < /dev/tty

        if [[ "$char" == $'\e' ]]; then
            # Use stty to check if there is more data pending in the buffer
            # This is much more reliable than -t 0.01 in Bash 3.2
            local next_chars=""
            stty -icanon -echo min 0 time 0
            next_chars=$(dd bs=3 count=1 2>/dev/null)
            stty icanon echo
            
            case "$next_chars" in
                "[D") (( pos > 0 )) && ((pos--)) ;; # Left
                "[C") (( pos < ${#val} )) && ((pos++)) ;; # Right
                "") _hide_cursor; return 1 ;; # ESC (Nothing followed the \e)
                *) : ;; # Ignore Up/Down
            esac
            continue
        elif [[ -z "$char" ]]; then
            break
        elif [[ "$char" == $'\t' ]]; then
            continue
        elif [[ "$char" == $'\177' || "$char" == $'\10' ]]; then
            if (( pos > 0 )); then
                local left="${val:0:pos-1}"
                local right="${val:pos}"
                val="${left}${right}"
                ((pos--))
            fi
        else
            # Insert logic
            local left="${val:0:pos}"
            local right="${val:pos}"
            val="${left}${char}${right}"
            ((pos++))
        fi
        
        # Clamp length
        if (( ${#val} > 34 )); then
            val="${val:0:34}"
            (( pos > 34 )) && pos=34
        fi
    done

    _hide_cursor
    local snap_line; printf -v snap_line "%*s" "$MAX_WIDTH" ""
    printf "\e[${phys_row};${PADDING_LEFT}H${BG_MAIN_ESC}%s" "$snap_line" >&2
    TUI_RESULT="$val"
    echo "$val"
}

passwordbox() {
    local title=$1 msg=$2 val="${3:-}" char key
    _init_tui
    _draw_header "$title" "$msg"

    local input_row=$row
    local phys_row=$((input_row + PADDING_TOP))

    while true; do
        _hide_cursor
        
        local masked_val="${val//?/*}"
        
        _draw_at "$input_row"
        printf "  ${BG_INPUT_ESC}${FG_INPUT_ESC} > %-34s ${RESET}${BG_MAIN_ESC}" "$masked_val" >&2
        
        # Position cursor at the end of the asterisks
        printf "\e[${phys_row};$((PADDING_LEFT + 5 + ${#masked_val}))H" >&2
        _show_cursor

        IFS= read -rsn1 char < /dev/tty

        if [[ "$char" == $'\e' ]]; then
            # Non-blocking buffer check for Bash 3.2
            local next_chars=""
            stty -icanon -echo min 0 time 0
            next_chars=$(dd bs=3 count=1 2>/dev/null)
            stty icanon echo
            
            case "$next_chars" in
                "") _hide_cursor; return 1 ;; # Standalone ESC - Cancel
                *) : ;; # Ignore arrows/sequences - prevents "typing" them in
            esac
            continue
        elif [[ -z "$char" ]]; then 
            break
        elif [[ "$char" == $'\t' ]]; then
            continue
        elif [[ "$char" == $'\177' || "$char" == $'\10' ]]; then 
            val="${val%?}"
        else
            # Append character (limit to 34 chars)
            if (( ${#val} < 34 )); then
                val="${val}${char}"
            fi
        fi
    done

    _hide_cursor
    # Snap background
    local snap_line; printf -v snap_line "%*s" "$MAX_WIDTH" ""
    printf "\e[${phys_row};${PADDING_LEFT}H${BG_MAIN_ESC}%s" "$snap_line" >&2
    
    _draw_footer
    TUI_RESULT="$val"
    echo "$val"
}

infobox() {
    local title=$1 msg=$2
    _init_tui

    _draw_header "$title" "$msg"

    _draw_footer

    # 5. Wait for user input before returning
    # This keeps the box on screen (so it doesn't vanish immediately)
    [[ "$TUI_MODAL" = "true" ]] && IFS= read -rsn1 _ < /dev/tty
}

gauge() {
    local title=$1 msg=$2 pct
    _init_tui

    while read -r pct; do
        _draw_header "$title" "$msg (${pct}%)"

        # Progress Bar Logic
        local width=40
        local fill=$((pct * width / 100))
        local empty=$((width - fill))

        _draw_at "$row"; printf "  " >&2
        printf "${BG_BLUE_ESC}%*s" "$fill" "" >&2
        printf "${BG_WID_ESC}%*s" "$empty" "" >&2
        
        # Snap the border and close the line
        _draw_line "" "$row"

        #((row++))
        _draw_footer
    done
}

textbox() {
    local title=$1 src=$2 top=0
    local last_top=-1
    local box_width=$(( MAX_WIDTH - 6 ))
    
    [[ ! -f "$src" ]] && { msgbox "Error" "File not found: $src"; return 1; }

    # Bash 3.2 Compatible file loading
    local lines=()
    local old_ifs="$IFS"
    IFS=$'\n'
    set -f
    lines=($(cat "$src"))
    set +f
    IFS="$old_ifs"
    local count=${#lines[@]}

    _init_tui
    while true; do
        if [[ $top -ne $last_top ]]; then
            _draw_header "$title" "File: $src"

            local view_top=$row
            local height=$(( MAX_HEIGHT - view_top - 2 ))
            [[ $height -lt 3 ]] && height=3

            # 1. PRE-RENDER the viewport
            for ((i=0; i<height; i++)); do
                local idx=$((top + i))
                local current_view_row=$((view_top + i))
                
                _draw_at "$current_view_row"
                printf "  " >&2 

                if [[ $idx -lt $count ]]; then
                    # OPTIMIZATION: Use Bash variable expansion instead of echo/expand/cut
                    local content="${lines[$idx]}"
                    # Replace tabs with 4 spaces (internal Bash 3.2)
                    content="${content//$'\t'/    }"
                    # Truncate string to box_width using parameter expansion
                    content="${content:0:$box_width}"
                    
                    _draw_item "text" 0 0 "$content" "$box_width"
                else
                    # Clear leftover lines
                    _draw_item "text" 0 0 "" "$box_width"
                fi
                
                _draw_line "" "$current_view_row"
            done
            
            row=$((view_top + height))
            _draw_line "" 
            _draw_controls " [Up/Down/j/k] Scroll | [Enter] Close"
            _draw_footer
            last_top=$top
        fi

        # 2. IMPROVED Input Handling (No lag)
        local key; IFS= read -rsn1 key < /dev/tty
        if [[ $key == $'\e' ]]; then
            read -rsn2 key
            case "$key" in
                "[A") [[ $top -gt 0 ]] && ((top--)) ;;
                "[B") [[ $((top + height)) -lt $count ]] && ((top++)) ;;
            esac
        elif [[ $key == "k" ]]; then
            [[ $top -gt 0 ]] && ((top--))
        elif [[ $key == "j" ]]; then
            [[ $((top + height)) -lt $count ]] && ((top++))
        elif [[ -z $key ]]; then
            return 0
        fi
    done
}

tailbox() {
    local title=$1 src=$2
    local box_width=$(( MAX_WIDTH - 6 ))
    [[ ! -f "$src" ]] && { msgbox "Error" "File not found: $src"; return 1; }
    
    _init_tui
    while true; do
        # 1. Header and Controls
        _draw_header "$title (Tail)" "File: $src"
        _draw_controls " Watching file... | [Enter] Close"
        _draw_line "" 

        # 2. Dynamic Height Calculation (same as textbox)
        local view_top=$row
        local height=$(( MAX_HEIGHT - view_top - 1 ))
        [[ $height -lt 3 ]] && height=3

        # 3. Content Logic
        local lines=(); IFS=$'\n' read -d '' -r -a lines < "$src"
        local count=${#lines[@]}
        local top=$(( count - height ))
        [[ $top -lt 0 ]] && top=0

        # 4. Content Viewport
        for ((i=0; i<height; i++)); do
            local idx=$((top + i))
            local current_view_row=$((view_top + i))
            
            _draw_at "$current_view_row"
            printf "  " >&2 

            if [[ $idx -lt $count ]]; then
                # Expand tabs and cut to width to keep the box straight
                local content=$(echo "${lines[$idx]}" | expand -t 4 | cut -c 1-"$box_width")
                _draw_item "text" 0 0 "$content" "$box_width"
            fi
            
            # Snap the border
            _draw_line "" "$current_view_row"
        done

        # 5. Cleanup Footer
        row=$((view_top + height))
        _draw_footer

        # 6. Non-blocking input (1s refresh)
        local key; IFS= read -rsn1 -t 1 key
        # Return 0 on Enter (empty key)
        [[ -n "$key" || $? -eq 0 ]] && [[ -z "$key" ]] && return 0
    done
}

form() {
    local title=$1 msg=$2; shift 2
    local raw_fields=("$@") count=${#raw_fields[@]}
    local fields=() values=() field_meta=() cur=0

    # --- 1. DSL PRE-PARSER (Fixed to preserve TUI markers) ---
    for ((i=0; i<count; i++)); do
        local line="${raw_fields[i]}"
        
        if [[ "$line" == "---" ]]; then
            fields[i]="---"; values[i]=""; field_meta[i]="sep"

        # --- INPUT & PASSWORD ---
        elif [[ "$line" == ">"* ]]; then
            # Format: "> Label:varname=default" or ">* Label:varname"
            local prefix="> "
            [[ "$line" == ">*"* ]] && prefix=">* "
            
            local content="${line#$prefix}"
            local label_var="${content%%=*}"
            local val="${content#*=}"
            [[ "$val" == "$content" ]] && val=""

            local lbl="${label_var%%:*}"
            local var="${label_var#*:}"
            [[ "$var" == "$lbl" ]] && var="${lbl,,}"
            
            # Re-attach prefix so _draw_form_field recognizes it
            fields[i]="${prefix}${lbl}"
            values[i]="$val"
            field_meta[i]="input|$var"

        # --- CHECKBOX ---
        elif [[ "$line" == "["* ]]; then
            # Format: "[ ] Label:varname" or "[x] Label:varname"
            local content="${line:4}" # Strip "[ ] " or "[x] "
            local lbl="${content%%:*}"
            local var="${content#*:}"
            
            # Store the standard "[ ] " prefix for the renderer
            fields[i]="[ ] ${lbl}"
            values[i]=$([[ "$line" == *"[x]"* ]] && echo "1" || echo "0")
            field_meta[i]="check|$var"

        # --- RADIO ---
        elif [[ "$line" == "("* ]]; then
            # Format: "( ) Label:varname" or "(*) Label:varname"
            local content="${line:4}" # Strip "( ) " or "(*) "
            local lbl="${content%%:*}"
            local var="${content#*:}"
            
            # Store the standard "( ) " prefix for the renderer
            fields[i]="( ) ${lbl}"
            values[i]=$([[ "$line" == *"(*)"* ]] && echo "1" || echo "0")
            field_meta[i]="radio|$var"

        else
            fields[i]="$line"; values[i]=""; field_meta[i]="text"
        fi
    done

    # 1. Initialize TUI first to get the correct MAX_WIDTH/MAX_HEIGHT for the mode
    _init_tui

    # 2. Width: Exactly 2 spaces less than half of the current MAIN_BG
    local form_width=$(( (MAX_WIDTH / 2) - 2 ))

    # 3. Alignment: Start at the left of the container
    local COL_START=0

    while true; do
        _draw_header "$title" "$msg"
        
        # 4. FIX: Position the start row UNDER the title/header
        # If your header takes 3 lines, we start at 4.
        row=$(( _get_start_row + 5 ))

        for ((i=0; i<count; i++)); do
            local active=0; (( i == cur )) && active=1
            
            if [[ "${fields[i]}" == "---" ]]; then
                 _draw_at "$row"
                 # Separator matches the new half-width
                 local box_w=$(( form_width - 2 )) 
                 local dashes; printf -v dashes "%*s" "$box_w" ""; dashes="${dashes// /-}"
                 printf "  ${FG_HINT_ESC}%s${RESET}${BG_MAIN_ESC}" "$dashes" >&2
                 ((row += 2))
            else
                 # Pass the calculated half-width and left-alignment
                 _draw_form_field "${fields[i]}" "${values[i]}" "$active" "$i" "$form_width" "$COL_START"
            fi
        done
        
        _draw_footer
        # Position controls at the bottom relative to MAX_HEIGHT
        row=$(( MAX_HEIGHT - 1 ))
        _draw_controls "[TAB/Arrows] Nav | [Space] Toggle | [Enter] Submit"

        local key; IFS= read -rsn1 key < /dev/tty
        if [[ $key == $'\e' ]]; then
            read -rsn2 key
            IFS='|' read -r state s_idx query opts <<< "${values[$cur]}"
            if [[ "$state" == "OPEN" ]]; then
                # --- CASE INSENSITIVE FILTER LOGIC ---
                local f=(); IFS=',' read -r -a all <<< "$opts"
                local l_q=$(echo "$query" | tr '[:upper:]' '[:lower:]')
                for o in "${all[@]}"; do
                    local l_o=$(echo "$o" | tr '[:upper:]' '[:lower:]')
                    [[ -z "$query" || "$l_o" == *"$l_q"* ]] && f+=("$o")
                done
                [[ $key == "[A" && $s_idx -gt 0 ]] && ((s_idx--))
                [[ $key == "[B" && $s_idx -lt $((${#f[@]}-1)) ]] && ((s_idx++))
                values[$cur]="$state|$s_idx|$query|$opts"; continue
            else
                if [[ $key == "[A" ]]; then while [[ $cur -gt 0 ]]; do ((cur--)); [[ "${fields[$cur]}" =~ ^([>\[\(\{]) ]] && break; done
                elif [[ $key == "[B" ]]; then while [[ $cur -lt $((count-1)) ]]; do ((cur++)); [[ "${fields[$cur]}" =~ ^([>\[\(\{]) ]] && break; done; fi
            fi
            continue
        fi

        case "$key" in
            $'\t') while true; do ((cur++)); [[ $cur -eq $count ]] && cur=0; [[ "${fields[$cur]}" =~ ^([>\[\(\{]) ]] && break; done ;;
            " ")
                IFS='|' read -r state s_idx query opts <<< "${values[$cur]}"
                if [[ "${fields[$cur]}" == "{"* ]]; then
                    if [[ "$state" == "OPEN" ]]; then
                        local f=(); IFS=',' read -r -a all <<< "$opts"
                        local l_q=$(echo "$query" | tr '[:upper:]' '[:lower:]')
                        for o in "${all[@]}"; do
                            local l_o=$(echo "$o" | tr '[:upper:]' '[:lower:]')
                            [[ -z "$query" || "$l_o" == *"$l_q"* ]] && f+=("$o")
                        done
                        local picked="${f[$s_idx]}"; IFS=',' read -r -a orig <<< "$opts"
                        for idx in "${!orig[@]}"; do [[ "${orig[$idx]}" == "$picked" ]] && { values[$cur]="CLOSED|$idx||$opts"; break; }; done
                    else values[$cur]="OPEN|0||$opts"; fi
                elif [[ "${fields[$cur]}" == "["* ]]; then values[$cur]=$(( 1 - ${values[$cur]:-0} ))
                elif [[ "${fields[$cur]}" == "("* ]]; then
                    local s=$cur; while [[ $s -gt 0 && "${fields[$((s-1))]}" == "("* ]]; do ((s--)); done
                    local e=$cur; while [[ $e -lt $((count-1)) && "${fields[$((e+1))]}" == "("* ]]; do ((e++)); done
                    for ((j=s; j<=e; j++)); do values[$j]=0; done; values[$cur]=1
                else values[$cur]="${values[$cur]} "; fi ;;
            $'\177'|$'\b')
                # --- BACKSPACE FIX FOR FILTERED DROPDOWNS ---
                IFS='|' read -r state s_idx query opts <<< "${values[$cur]}"
                if [[ "${fields[$cur]}" == "{>}"* && "$state" == "OPEN" ]]; then
                    query="${query%?}"; values[$cur]="$state|0|$query|$opts"
                else values[$cur]="${values[$cur]%?}"; fi ;;
            "") # Enter / Submit
                local res=""
                local last_label=""
                
                for ((i=0; i<count; i++)); do
                    local meta="${field_meta[i]}"
                    local type="${meta%%|*}"
                    local varname="${meta#*|}"
                    local val="${values[i]}"
                    local field_raw="${fields[i]}"

                    case "$type" in
                        "text")
                            # Bash 3.2 lowercase/clean trick
                            local clean=$(echo "${field_raw%%:*}" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
                            last_label="$clean"
                            ;;
                        "input")
                            res="${res}${varname}='${val}'"$'\n'
                            ;;
                        "check")
                            # Export as true/false strings for shell eval compatibility
                            [[ "$val" == "1" ]] && res="${res}${varname}='true'"$'\n' || res="${res}${varname}='false'"$'\n'
                            ;;
                        "radio")
                            if [[ "$val" == "1" ]]; then
                                res="${res}${last_label}='${varname}'"$'\n'
                            fi
                            ;;
                    esac
                done

                # 1. Store the literal newline version for the Config File logic
                TUI_RESULT="${res%$'\n'}"
                
                # 2. Output a space-separated version to stdout for legacy FORM_DATA capture
                # but ensure TUI_RESULT remains multiline for the '&& echo' chain
                echo "${TUI_RESULT//$'\n'/ }" && return 0 ;;

            *) 
                # Use standard pattern matching for printable keys from TTY
                if [[ "$key" == [[:print:]] ]]; then
                    IFS='|' read -r state s_idx query opts <<< "${values[$cur]}"
                    if [[ "${fields[$cur]}" == "{>}"* && "$state" == "OPEN" ]]; then
                        query="${query}${key}"; values[$cur]="$state|0|$query|$opts"
                    elif [[ "${fields[$cur]}" == ">"* ]]; then 
                        values[$cur]="${values[$cur]}${key}"; 
                    fi
                fi ;;
        esac
    done
}

_save_undo() {
    # Limit stack size to 20 to prevent disk bloat
    tail -n 20 "$undo_stack" > "${undo_stack}.tmp"
    # Append current state as a single line (convert commas to | for stack)
    cat "$tmp_csv" >> "$undo_stack"
    : > "$redo_stack" # New action clears redo
}

spreadsheet() {
    # --- Spreadsheet Features ---
    # Navigation: Arrow keys for cell movement; scrollable row/column viewport
    # Modes: NAV (movement/commands) and EDIT (text entry via ENTER)
    # Math: Basic operators (+, -, *, /) and cell references (e.g., =A1+B1)
    # Stats: SUM, AVG, MIN, MAX, COUNT, COUNTA (e.g., =SUM(A1:B10))
    # Logic: IF statements with multi-char operators (e.g., =IF(A1>=50,OK,FAIL))
    # Strings: Concatenation using & operator (e.g., =A1&B1)
    # Formatting: ROUND function for decimal precision (e.g., =ROUND(A1,2))
    # Clipboard: Instant X (cut), C (copy), V (paste) in NAV mode
    # History: Multi-level Undo (z) and Redo (Z) support
    # Data: Persistence via CSV; handles row growth and empty cell alignment

    local MAX_COLS=26
    local src="$1"
    local tmp_csv=$(mktemp)
    
    # 1. Setup Stacks and Clipboard
    local clipboard_val=""
    local undo_idx=0 redo_idx=0
    rm -f /tmp/tui_undo_* /tmp/tui_redo_*

    # 2. Setup Initial Data
    [[ -f "$src" ]] && cp "$src" "$tmp_csv" || echo "10,20,30" > "$tmp_csv"

    # 3. Define Undo Helper OUTSIDE the loop
    _push_undo() {
        ((undo_idx++))
        cp "$tmp_csv" "/tmp/tui_undo_${undo_idx}.csv"
        # New actions invalidate redo history
        rm -f /tmp/tui_redo_*
        redo_idx=0
    }

    local cur_r=1 cur_c=1 top_r=1 top_c=1
    local mode="NAV" edit_val=""

    _init_tui
    while true; do
        # Viewport Math
        local v_h=$((MAX_HEIGHT - 9))
        local col_w=12 
        local v_w_area=$((MAX_WIDTH - 11)) 
        local v_c_count=$((v_w_area / (col_w + 1) + 1))

        [[ $cur_r -lt $top_r ]] && top_r=$cur_r
        [[ $cur_r -ge $((top_r + v_h)) ]] && top_r=$((cur_r - v_h + 1))
        [[ $cur_c -lt $top_c ]] && top_c=$cur_c
        [[ $cur_c -ge $((top_c + v_c_count)) ]] && top_c=$((cur_c - v_c_count + 1))

        # 4. Rendering Logic
        # 2. Render with Strict Width Math

        # 1. Header Fix: Use _draw_line or a clamped printf to stop the bleed
        _draw_header "SPREADSHEET" "Mode: $mode | [Arrows] Move  [Enter] Confirm  [z/Z] Undo/Redo  [q] Quit  "
        # Wipe the subtitle row perfectly to the right edge
        _draw_at "$((row - 1))" 0; printf "${BG_MAIN_ESC}%*s" "$MAX_WIDTH" "" >&2

        # 2. Spreadsheet Body (Using your fixed width)
        local visible_h=$((MAX_HEIGHT - 9))
        local col_w=12 
        local v_w_area=$((MAX_WIDTH - 11)) # Your fix
        local v_c_count=$((v_w_area / (col_w + 1)))


        # 2. Tight math for the Grid
        local grid_data
        grid_data=$(awk -v cur_r="$cur_r" -v cur_c="$cur_c" \
                        -v top_r="$top_r" -v top_c="$top_c" \
                        -v h="$v_h" -v v_c="$v_c_count" \
                        -v col_w="$col_w" -v w="$MAX_WIDTH" \
                        -v bg_m_raw="$BG_MAIN" -v bg_a_raw="$BG_ACTIVE" \
                        -v pt="$PADDING_TOP" -v pl="$PADDING_LEFT" \
            'BEGIN { FS=","; 
                bm="\033[48;2;"bg_m_raw"m"; ba="\033[48;2;"bg_a_raw"m\033[1m"; 
                bh="\033[48;2;80;80;80m\033[38;2;200;200;200m"; 
                abc="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            }
            { for(i=1; i<=NF; i++) d[NR,i]=$i; }
            function res(v,  tc, tr) {
                v = toupper(v);
                if(v ~ /^[A-Z][0-9]+$/) {
                    # Ensure A matches 1, B matches 2
                    tc = index(abc, substr(v,1,1));
                    tr = substr(v,2); 
                    return d[tr,tc] + 0;
                }
                return v + 0;
            }
            function ev(f,  p, op, s, sc, sr, ec, er, r, c, val, count, min, max, c_num, c_all, n1, n2) {
                f = toupper(f); sub(/^=/, "", f);
                
                # --- RANGE FUNCTIONS ---
                if (f ~ /^(SUM|AVG|MIN|MAX|COUNT|COUNTA)\(/) {
                    op = substr(f, 1, index(f, "(") - 1);
                    sub(/^[A-Z]+\(/, "", f); sub(/\)/, "", f);
                    split(f, p, ":");
                    sc = index(abc, substr(p[1],1,1)); sr = substr(p[1],2);
                    ec = index(abc, substr(p[2],1,1)); er = substr(p[2],2);
                    s = 0; c_num = 0; c_all = 0;
                    min = 999999999; max = -999999999;
                    for(r=sr; r<=er; r++) {
                        for(c=sc; c<=ec; c++) {
                            val = d[r,c]; if (val == "") continue;
                            c_all++;
                            if (val ~ /^-?[0-9.]+$/) {
                                num = val + 0; s += num; c_num++;
                                if (num < min) min = num; if (num > max) max = num;
                            }
                        }
                    }
                    if (op == "SUM") return s;
                    if (op == "AVG") return (c_num > 0) ? s / c_num : 0;
                    if (op == "MIN") return (c_num > 0) ? min : 0;
                    if (op == "MAX") return (c_num > 0) ? max : 0;
                    if (op == "COUNT") return c_num;
                    if (op == "COUNTA") return c_all;
                }
                
                # --- ROUND ---
                if (f ~ /^ROUND\(/) {
                    sub(/^ROUND\(/, "", f); sub(/\)/, "", f);
                    split(f, p, ",");
                    return sprintf("%." (p[2]+0) "f", res(p[1]));
                }
                
                # --- CONCAT ---
                if (f ~ /&/) {
                    split(f, p, "&");
                    return res(p[1]) res(p[2]);
                }

                # --- IF ---
                if (f ~ /^IF\(/) {
                    sub(/^IF\(/, "", f); sub(/\)/, "", f);
                    split(f, p, ",");
                    cond = p[1];
                    op = (cond ~ />=/) ? ">=" : ((cond ~ /<=/) ? "<=" : ((cond ~ />/) ? ">" : ((cond ~ /</) ? "<" : "=")));
                    split(cond, cp, op);
                    v1 = res(cp[1]); v2 = res(cp[2]);
                    rb = 0;
                    if(op==">=") rb=(v1>=v2); else if(op=="<=") rb=(v1<=v2);
                    else if(op==">") rb=(v1>v2); else if(op=="<") rb=(v1<v2); else rb=(v1==v2);
                    return rb ? p[2] : p[3];
                }

                # --- MATH ---
                op = (f~/\+/)?"+":((f~/-/)?"-":((f~/\*/)?"*":((f~/\//)?"/":"")));
                if (op != "") {
                    split(f, p, op); n1 = res(p[1]); n2 = res(p[2]);
                    if(op=="+") return n1+n2; if(op=="-") return n1-n2;
                    if(op=="*") return n1*n2; return (n2==0)?"DIV/0":n1/n2;
                }
                return f;
            }
            END {
                row_num_w = 4;
                # --- HEADER ---
                printf "\033[%d;%dH%s  %*s", (pt+6), (pl+1), bm, row_num_w, "";
                used = 4 + row_num_w;
                for(c=top_c; c<(top_c + v_c); c++) {
                    printf "%s %-*.*s %s", bh, col_w, col_w, substr(abc,c,1), bm;
                    used += (col_w + 2);
                }
                # Fill remaining gap to right edge exactly
                if (w > used) printf "%*s", (w - used), "";

                # --- ROWS ---
                for(r=top_r; r<(top_r + h); r++) {
                    ry=r-top_r+pt+7;
                    printf "\033[%d;%dH%s  %2d %s", ry, (pl+1), bh, r, bm;
                    used = 2 + row_num_w;
                    for(c=top_c; c<(top_c + v_c); c++) {
                        s=(r==cur_r && c==cur_c)?ba:bm; v=d[r,c];
                        if(v ~ /^=/) v=ev(v);
                        if(v == "") v=" ";
                        printf "%s %-*.*s %s", s, col_w, col_w, v, bm;
                        used += (col_w + 2);
                    }
                    # Fill remaining gap to right edge exactly
                    if (w > used) printf "%*s", (w - used), "";
                }
            }' "$tmp_csv")

        printf "%b" "$grid_data" >&2
        
        # 3. Status Bar - Fixed width with truncation and trailing fill
        _draw_at "$((MAX_HEIGHT - 1))" 0
        local bar_limit=$((MAX_WIDTH - 5)) # Buffer for indents
        
        if [[ "$mode" == "EDIT" ]]; then
            local label=" EDIT: "
            local val_limit=$(( bar_limit - ${#label} ))
            printf "  ${BG_INPUT_ESC}${FG_INPUT_ESC}${label}%-${val_limit}.${val_limit}s ${RESET}${BG_MAIN_ESC}  " "$edit_val" >&2
        else
            local raw=$(awk -F, -v r="$cur_r" -v c="$cur_c" 'NR==r{print $c}' "$tmp_csv")
            local label=" [$(printf \\$(printf '%03o' $((cur_c+64))))${cur_r}] Raw: "
            local val_limit=$(( bar_limit - ${#label} ))
            printf "  ${FG_HINT_ESC}${label}%-${val_limit}.${val_limit}s ${RESET}${BG_MAIN_ESC}  " "$raw" >&2
        fi

        # 6. Input Handling
        local key
        IFS= read -rsn1 key < /dev/tty

        # --- ENTER KEY HANDLER ---
        if [[ -z "$key" || "$key" == $'\r' || "$key" == $'\n' ]]; then
            if [[ "$mode" == "NAV" ]]; then
                mode="EDIT"
                edit_val=$(awk -F, -v r="$cur_r" -v c="$cur_c" 'NR==r{print $c}' "$tmp_csv")
            else
                _push_undo
                local row_count=$(wc -l < "$tmp_csv")
                while [[ $row_count -lt $cur_r ]]; do
                    local pad=""; for ((i=1; i<MAX_COLS; i++)); do pad+=","; done
                    echo "$pad" >> "$tmp_csv"; ((row_count++))
                done

                # REBUILDER: The only way to prevent the "Shift to Column A" in BusyBox
                awk -F, -v r="$cur_r" -v c="$cur_c" -v nv="$edit_val" -v mc="$MAX_COLS" '
                    BEGIN { OFS="," }
                    NR == r {
                        # 1. Force the line into a clean array using the comma separator
                        # This is more reliable in BusyBox than using $i
                        n = split($0, row, ",")
                        
                        # 2. Update the specific index
                        row[c] = nv
                        
                        # 3. Manually stringify the array back to mc (26) columns
                        out = ""
                        for (i = 1; i <= mc; i++) {
                            val = row[i]
                            # Ensure index exists in output string even if it was null in input
                            out = (i == 1) ? val : out OFS val
                        }
                        print out; next
                    }
                    { print $0 }' "$tmp_csv" > "${tmp_csv}.tmp" && mv "${tmp_csv}.tmp" "$tmp_csv"
                mode="NAV"
            fi
            continue
        fi

        # --- FIX: Handle NAV mode shortcuts (x, c, v) FIRST ---
        if [[ "$mode" == "NAV" ]]; then
            case "$key" in
                "c")
                    clipboard_val=$(awk -F, -v r="$cur_r" -v c="$cur_c" 'NR==r{print $c}' "$tmp_csv")
                    continue
                    ;;
                "x"|"v")
                    _push_undo
                    
                    local target_val=""
                    if [[ "$key" == "x" ]]; then
                        clipboard_val=$(awk -F, -v r="$cur_r" -v c="$cur_c" 'NR==r{print $c}' "$tmp_csv")
                        target_val=""
                    else
                        target_val="$clipboard_val"
                    fi

                    local row_count=$(wc -l < "$tmp_csv")
                    while [[ $row_count -lt $cur_r ]]; do
                        local pad_line=""; for ((i=1; i<MAX_COLS; i++)); do pad_line+=","; done
                        echo "$pad_line" >> "$tmp_csv"
                        ((row_count++))
                    done
                    # Use nv="$target_val" instead of "$edit_val"
                    awk -F, -v r="$cur_r" -v c="$cur_c" -v nv="$target_val" -v mc="$MAX_COLS" '
                        BEGIN { OFS="," }
                        NR == r {
                            # 1. Force the line into a clean array using the comma separator
                            # This is more reliable in BusyBox than using $i
                            n = split($0, row, ",")
                            
                            # 2. Update the specific index
                            row[c] = nv
                            
                            # 3. Manually stringify the array back to mc (26) columns
                            out = ""
                            for (i = 1; i <= mc; i++) {
                                val = row[i]
                                # Ensure index exists in output string even if it was null in input
                                out = (i == 1) ? val : out OFS val
                            }
                            print out; next
                        }
                        { print $0 }' "$tmp_csv" > "${tmp_csv}.tmp" && mv "${tmp_csv}.tmp" "$tmp_csv"
                    continue
                    ;;
            esac
        fi

        case "$key" in
            "z") # UNDO
                if [[ $undo_idx -gt 0 ]]; then
                    ((redo_idx++))
                    cp "$tmp_csv" "/tmp/tui_redo_${redo_idx}.csv"
                    cp "/tmp/tui_undo_${undo_idx}.csv" "$tmp_csv"
                    rm -f "/tmp/tui_undo_${undo_idx}.csv"
                    ((undo_idx--))
                fi
                ;;
            "Z") # REDO
                if [[ $redo_idx -gt 0 ]]; then
                    ((undo_idx++))
                    cp "$tmp_csv" "/tmp/tui_undo_${undo_idx}.csv"
                    cp "/tmp/tui_redo_${redo_idx}.csv" "$tmp_csv"
                    rm -f "/tmp/tui_redo_${redo_idx}.csv"
                    ((redo_idx--))
                fi
                ;;
            $'\e')
                read -rsn2 key < /dev/tty
                [[ "$mode" == "NAV" ]] && case "$key" in
                    "[A") [[ $cur_r -gt 1 ]] && ((cur_r--)) ;;
                    "[B") ((cur_r++)) ;;
                    "[C") [[ $cur_c -lt $MAX_COLS ]] && ((cur_c++)) ;;
                    "[D") [[ $cur_c -gt 1 ]] && ((cur_c--)) ;;
                esac
                ;;
            "q"|"Q") [[ "$mode" == "NAV" ]] && break ;;
            $'\177'|$'\010') [[ "$mode" == "EDIT" ]] && edit_val="${edit_val%?}" ;;
            *)
                # CRITICAL: Only append to edit_val if we are actually in EDIT mode
                # This prevents "v" or "x" from being added to the buffer in NAV mode
                [[ "$mode" == "EDIT" ]] && edit_val+="$key" 
                ;;
        esac
    done
    cat "$tmp_csv"
    rm -f "$tmp_csv" /tmp/tui_undo_* /tmp/tui_redo_*
}

filtermenu() {
    local title=$1 msg=$2 d=0 input_string=""
    
    # Check if $3 is a numeric index
    if [[ "$3" =~ ^[0-9]+$ ]]; then
        # Natural index: 0 = First Item, 1 = Second Item
        # We add +1 because cur=0 is the Filter Input box
        d=$(( $3 ))
        input_string=$4
    else
        input_string=$3
    fi    

    local old_ifs="$IFS"
    IFS=$'\n'
    set -f
    local all_options=($(echo "$input_string" | sed '/^[[:space:]]*$/d; s/^[[:space:]]*//; s/[[:space:]]*$//'))
    set +f
    IFS="$old_ifs"
    
    local filter_query=""
    local last_query="INIT_STATE"
    local cur=$d # Set initial focus
    local scroll_offset=0
    local box_width=$(( MAX_WIDTH - 6 ))
    local start_row=$(_get_start_row)

    _init_tui
    while true; do
        row=$start_row

        # 1. OPTIMIZED Filter logic
        if [[ "$filter_query" != "$last_query" ]]; then
            local filtered=()
            local opt
            shopt -s nocasematch
            for opt in "${all_options[@]}"; do
                if [[ -z "$filter_query" || "$opt" == *"$filter_query"* ]]; then
                    filtered[${#filtered[@]}]="$opt"
                fi
            done
            shopt -u nocasematch
            count=${#filtered[@]}
            last_query="$filter_query"
        fi

        # 2. Viewport Geometry
        local max_vh=$(( MAX_HEIGHT - 9 )) 
        [[ $max_vh -lt 3 ]] && max_vh=3

        # 3. Header & Search
        _draw_header "$title" "$msg"
        _draw_at "$row"
        
        # UI Focus Styles
        local style="${BG_WID_ESC}${FG_TEXT_ESC}"
        [[ $cur -eq 0 ]] && style="${BG_INPUT_ESC}${FG_BLUE_BOLD}"
        
        printf "  Filter: ${style} > %-25s ${RESET}${BG_MAIN_ESC}%$((MAX_WIDTH - 39))s" "$filter_query" "" >&2
        _draw_line "" "$row"
        _draw_line "" 
        
        # 4. Scroll Logic (Viewport Math)
        local active_vh=$count
        [[ $active_vh -gt $max_vh ]] && active_vh=$max_vh
        [[ $active_vh -lt 1 ]] && active_vh=1

        # Ensure cur stays in bounds after filtering
        [[ $cur -gt $count ]] && cur=$count

        if [[ $((cur - 1)) -lt $scroll_offset && $cur -gt 0 ]]; then
            scroll_offset=$((cur - 1))
        elif [[ $((cur - 1)) -ge $((scroll_offset + active_vh)) ]]; then
            scroll_offset=$((cur - active_vh))
        fi

        # 5. Viewport Loop
        local list_top=$row
        for ((i=0; i<max_vh; i++)); do
            local idx=$((scroll_offset + i))
            local current_row=$((list_top + i))
            _draw_at "$current_row"
            printf "  " >&2 
            local is_cur=0; [[ $((cur - 1)) -eq $idx ]] && is_cur=1
            
            if [[ $idx -lt $count ]]; then
                _draw_item "menu" "$is_cur" 0 "${filtered[idx]}" "$box_width"
            else
                printf "${BG_MAIN_ESC}%-${box_width}s${RESET}${BG_MAIN_ESC}" "" >&2
            fi
            printf "%$((MAX_WIDTH - box_width - 4))s" "" >&2
            ((row++))
        done
        
        # 6. Pinned Footer & Controls
        local adjustment=0
        [[ "$TUI_MODE" == "fullscreen" ]] && adjustment=-1
        row=$((list_top + max_vh + adjustment))
        _draw_spacer
        _draw_controls " [Arrows/j/k] Move | [Enter] Select"
        _draw_footer

        # 7. Input Handling
        local key; IFS= read -rsn1 key < /dev/tty
        if [[ $key == $'\e' ]]; then
            read -rsn2 key
            case "$key" in
                "[A") [[ $cur -gt 0 ]] && ((cur--)) ;; 
                "[B") [[ $cur -lt $count ]] && ((cur++)) ;;
            esac
            continue
        fi

        case "$key" in
            "") 
                if [[ $cur -eq 0 ]]; then
                    [[ $count -gt 0 ]] && cur=1
                else 
                    TUI_RESULT="${filtered[$((cur-1))]}"
                    echo "${filtered[$((cur-1))]}"
                    return 0
                fi ;;
            k) if [[ $cur -gt 0 ]]; then ((cur--)); else filter_query="${filter_query}${key}"; fi ;;
            j) if [[ $cur -gt 0 ]]; then [[ $cur -lt $count ]] && ((cur++)); else filter_query="${filter_query}${key}"; fi ;;
            $'\177'|$'\b') filter_query="${filter_query%?}"; cur=0; scroll_offset=0 ;;
            *) if [[ $cur -eq 0 && "$key" == [[:print:]] ]]; then filter_query="${filter_query}${key}"; cur=0; scroll_offset=0; fi ;;
        esac
    done
}

preview() {
    local file=$1 row_start=$2 height=$3 col_start=$4
    local offset=${5:-0}
    local width=$(( MAX_WIDTH - col_start - 1 ))
    local absolute_col=$(( PADDING_LEFT + col_start - 2 ))
    
    # 1. Clear the preview area
    local clear_block=""
    printf -v spaces "%*s" "$width" ""
    for ((i=0; i<height; i++)); do
        clear_block+="\e[$((row_start + i + PADDING_TOP));${absolute_col}H${BG_MAIN_ESC}${spaces}"
    done
    printf "%b" "$clear_block" >&2

    [[ ! -f "$file" ]] && return

    local line_count=0
    local preview_content=""
    
    # 2. Optimized Reading & ANSI Stripping (Portable)
    # Stage 1: Strip ANSI (sed)
    # Stage 2: Slice lines (sed -n 'start,endp')
    while IFS= read -r line; do
        line="${line//$'\t'/    }"
        line="${line:0:width}"
        
        printf -v row_str "\e[$((row_start + line_count + PADDING_TOP));${absolute_col}H${FG_HINT_ESC}%-*s${RESET}${BG_MAIN_ESC}" "$width" "$line"
        preview_content+="$row_str"
        ((line_count++))
    done < <(sed $'s/\e[[][^A-Za-z]*[A-Za-z]//g' "$file" | sed -n "$((offset + 1)),$((offset + height))p")
    
    printf "%b" "$preview_content" >&2
}

file_navigator() {
    local title=$1 root_dir=${2:-.}
    # --- STARTUP FOCUS UPDATE ---
    # Default to 0 if not provided or empty
    local cur=${3:-0}
    
    local top=0 menu_w=30 
    local preview_x=$(( menu_w + 8 )) 
    local last_cur=-1 last_dir="INIT"
    local rebuild=1
    
    local dir_col="\e[1;34m" # Bold Blue
    local exe_col="\e[1;32m" # Bold Green
    local hid_col="\e[2m"    # Faint
    local show_hidden=0
    local selected_paths=() 

    root_dir=$(cd "$root_dir" && pwd)

    while true; do
        # 1. DATA: Rebuild on Dir change OR Hidden toggle
        if [[ "$root_dir" != "$last_dir" || $rebuild -eq 1 ]]; then
            raw_list=(); selected_paths=()
            
            # Add Parent Directory
            raw_list[${#raw_list[@]}]="${root_dir%/*}|..|true"
            selected_paths[${#selected_paths[@]}]=0
            
            shopt -s dotglob; shopt -s nocaseglob
            
            # Loop 1: Directories
            for path in "$root_dir"/*; do
                [[ ! -d "$path" ]] && continue
                local name="${path##*/}"
                [[ "$name" == "." || "$name" == ".." ]] && continue
                [[ $show_hidden -eq 0 && "$name" == .* ]] && continue
                
                raw_list[${#raw_list[@]}]="$path|$name|true"
                selected_paths[${#selected_paths[@]}]=0
            done

            # Loop 2: Files
            for path in "$root_dir"/*; do
                [[ ! -f "$path" ]] && continue
                local name="${path##*/}"
                [[ $show_hidden -eq 0 && "$name" == .* ]] && continue
                
                raw_list[${#raw_list[@]}]="$path|$name|false"
                selected_paths[${#selected_paths[@]}]=0
            done
            shopt -u dotglob; shopt -u nocaseglob
            
            count=${#raw_list[@]}

            # --- MAINTAIN FOCUS AFTER REBUILD ---
            if [[ $cur -eq -2 ]]; then
                cur=0 # Default if not found
                for ((idx=0; idx<count; idx++)); do
                    if [[ "${raw_list[$idx]%%|*}" == "$last_path" ]]; then
                        cur=$idx; break
                    fi
                done
            fi

            # --- STARTUP BOUNDS CHECK ---
            [[ $cur -ge $count ]] && cur=$((count - 1))
            [[ $cur -lt 0 ]] && cur=0

            last_dir="$root_dir"; rebuild=0; _init_tui 
        fi

        # --- PATH TRUNCATION FIX ---
        local display_path="$root_dir"
        local max_path_w=$(( MAX_WIDTH - 10 ))
        if [[ ${#display_path} -gt $max_path_w ]]; then
            display_path="...${display_path:$(( ${#display_path} - max_path_w + 3 ))}"
        fi
        _draw_header "$title" "Path: $display_path"

        local list_top=$row
        local height=$(( MAX_HEIGHT - list_top - 2 ))
        [[ $height -lt 5 ]] && height=5

        # --- VIEWPORT ADJUSTMENT ---
        # Ensure the list scrolls to show the focused item immediately
        if [[ $cur -lt $top ]]; then
            top=$cur
        elif [[ $cur -ge $((top + height)) ]]; then
            top=$((cur - height + 1))
        fi

        # 1. SIDEBAR RENDER
        for ((i=0; i<height; i++)); do
            local v_idx=$((top + i))
            local current_row=$((list_top + i))
            _draw_at "$current_row"
            printf "  " >&2 
            
            if [[ $v_idx -lt $count ]]; then
                local node="${raw_list[$v_idx]}"
                local path="${node%%|*}"
                local remain="${node#*|}"
                local label="${remain%|*}"
                local is_dir="${remain##*|}"

                local is_cur=0; [[ $v_idx -eq $cur ]] && is_cur=1
                
                local display_name="$label"
                [[ "$is_dir" == "true" && "$label" != ".." ]] && display_name="${label}/"

                local max_l=$(( menu_w - 2 ))
                if [[ ${#display_name} -gt $max_l ]]; then
                    display_name="${display_name:0:$((max_l - 2))}.."
                fi

                local color=""
                if [[ $is_cur -eq 1 ]]; then
                    color="\e[1;37m" 
                elif [[ "${selected_paths[$v_idx]}" -eq 1 ]]; then
                    color="\e[1;33m"
                elif [[ "$is_dir" == "true" ]]; then
                    color="$dir_col"
                elif [[ "$label" == .* ]]; then
                    color="$hid_col"
                elif [[ -x "$path" ]]; then
                    color="$exe_col"
                else
                    color="$FG_TEXT_ESC"
                fi

                local style=$BG_WID_ESC
                [[ $is_cur -eq 1 ]] && style=$HL_WHITE_BOLD
                
                printf "${style}${color} %-${menu_w}s ${RESET}${BG_MAIN_ESC}" "$display_name" >&2
            else
                printf "%$((menu_w + 2))s" "" >&2
            fi
            _draw_line "" "$current_row"
        done

        # 2. PREVIEW (Optimized Parse)
        if [[ $cur -ne $last_cur ]]; then
            local node="${raw_list[$cur]}"
            local p="${node%%|*}"
            local is_d="${node##*|}"
            if [[ "$is_d" == "false" ]];then
                preview "$p" "$list_top" "$height" "$preview_x" "$preview_offset"
            else
                preview "" "$list_top" "$height" "$preview_x" "$preview_offset"
            fi
            last_cur=$cur
        fi

        # 3. POSITION FOOTER
        row=$((list_top + height))
        _draw_spacer
        _draw_controls " [TAB] Mark | [BS] Hidden | [Enter] Select | [q] Quit"
        _draw_footer

        # 4. Handle inputs
        # Helper logic for "Selection" (shared by Enter and Right Arrow)
        # Returns: 0 = Continue Loop, 2 = Exit Success (File/Marked Selected)
        _handle_selection() {
            local results=""
            for ((idx=0; idx<count; idx++)); do
                [[ "${selected_paths[$idx]}" -eq 1 ]] && results+="${raw_list[$idx]%%|*}"$'\n'
            done
            
            if [[ -n "$results" ]]; then 
                TUI_RESULT="$results"
                printf "%b" "$results"
                return 2 
            fi

            local node="${raw_list[$cur]}"
            local p="${node%%|*}"
            local is_d="${node##*|}"

            if [[ "$is_d" == "true" ]]; then
                root_dir=$(cd "$p" && pwd); cur=0; top=0; last_cur=-1
                [[ -n "$TUI_CD_FILE" ]] && echo "cd \"$root_dir\"" > "$TUI_CD_FILE"
                _init_tui
                return 0
            else
                TUI_RESULT="$p"
                echo "$p"
                return 2
            fi
        }

        local key; IFS= read -rsn1 key < /dev/tty
        case "$key" in
            $'\t') # Mark
                selected_paths[$cur]=$(( 1 - ${selected_paths[$cur]} ))
                [[ $cur -lt $((count - 1)) ]] && ((cur++)) ;;
            $'\177'|$'\b') # Backspace
                local last_path="${raw_list[$cur]%%|*}"
                show_hidden=$(( 1 - show_hidden )); rebuild=1; cur=-2 ;;
            "q") return 1 ;;
            "") # Enter
                _handle_selection; [[ $? -eq 2 ]] && return 0 ;;
            $'\e')
                read -rsn2 key
                case "$key" in
                    "[A") [[ $cur -gt 0 ]] && ((cur--)) ;;
                    "[B") [[ $cur -lt $((count - 1)) ]] && ((cur++)) ;;
                    "[C") # Right Arrow
                        _handle_selection; [[ $? -eq 2 ]] && return 0 ;;
                    "[D") # Left Arrow (Back)
                        local old_name="${root_dir##*/}"
                        local parent_dir="${root_dir%/*}"
                        if [[ -n "$parent_dir" && "$root_dir" != "/" ]]; then
                            root_dir="$parent_dir"
                            last_path="$root_dir/$old_name"
                            rebuild=1; cur=-2
                            [[ -n "$TUI_CD_FILE" ]] && echo "cd \"$root_dir\"" > "$TUI_CD_FILE"
                            _init_tui
                        fi ;;
                esac ;;
        esac
    done
}

_tree_core() {
    local mode=$1 title=$2 msg=$3 def_idx=${4:-0}; shift 4
    local all_nodes=("$@") count=${#all_nodes[@]}
    local cur=$def_idx top=0
    # FIX: Reduce width to -6 to accommodate the 1-space indent AND _draw_item's padding
    local box_width=$(( MAX_WIDTH - 6 )) 

    # 1. New Filter State
    : ${ENABLE_FILTER:=false}
    local filter_query=""
    local last_query="INIT"

    local visible_indices=() formatted_lines=() expanded=()

    # Pre-populate the expanded array with every parent ID
    for node in "${all_nodes[@]}"; do
        if [[ "${node##*|}" == "true" ]]; then
            local rem="${node#*|}"
            expanded[${#expanded[@]}]="${rem%%|*}"
        fi
    done

    _update_tree_cache() {
        visible_indices=(); formatted_lines=()
        local last_hidden_depth=-1 
        local exp_str="|$(printf "%s|" "${expanded[@]}")"
        local is_filtering=0; [[ -n "$filter_query" ]] && is_filtering=1

        for i in "${!all_nodes[@]}"; do
            local node="${all_nodes[i]}"
            local depth="${node%%|*}"
            local remaining="${node#*|}"
            local id="${remaining%%|*}"; remaining="${remaining#*|}"
            local label="${remaining%%|*}"; local has_kids="${remaining##*|}"

            # --- 1. FILTER CALCULATION ---
            local match=0
            if [[ $is_filtering -eq 1 ]]; then
                shopt -s nocasematch
                # Logic: Match if Self, any Ancestor, or any Descendant matches
                if [[ "$label" == *"$filter_query"* || "$id" == *"$filter_query"* ]]; then
                    match=1
                else
                    # Check Ancestors
                    local scan_p=$i check_d=$depth
                    while [[ $scan_p -gt 0 ]]; do
                        ((scan_p--))
                        local p_node="${all_nodes[$scan_p]}"
                        if [[ "${p_node%%|*}" -lt $check_d ]]; then
                            local p_rem="${p_node#*|}"
                            if [[ "${p_rem#*|}" == *"$filter_query"* || "${p_rem%%|*}" == *"$filter_query"* ]]; then
                                match=1; break
                            fi
                            check_d="${p_node%%|*}"
                        fi
                    done
                    # Check Descendants
                    if [[ $match -eq 0 ]]; then
                        local scan_d=$((i + 1))
                        while [[ $scan_d -lt $count ]]; do
                            local d_node="${all_nodes[$scan_d]}"
                            [[ "${d_node%%|*}" -le $depth ]] && break
                            local d_rem="${d_node#*|}"
                            if [[ "${d_rem#*|}" == *"$filter_query"* || "${d_rem%%|*}" == *"$filter_query"* ]]; then
                                match=1; break
                            fi
                            ((scan_d++))
                        done
                    fi
                fi
                shopt -u nocasematch
                [[ $match -eq 0 ]] && continue
            fi

            # --- 2. HIERARCHY / EXPANSION LOGIC ---
            # If filtering, we ignore 'expanded' state and show the branch
            if [[ $is_filtering -eq 0 ]]; then
                if [[ $last_hidden_depth -ne -1 && $depth -gt $last_hidden_depth ]]; then
                    continue
                fi
                last_hidden_depth=-1
                if [[ "$has_kids" == "true" && "$exp_str" != *"|$id|"* ]]; then
                    last_hidden_depth=$depth
                fi
            fi

            # --- 3. RENDER ---
            visible_indices[${#visible_indices[@]}]=$i
            local indent=""; for ((d=0; d<depth; d++)); do indent="  $indent"; done
            
            # Icon logic: If filtering, force "▼" for matching parents so user sees they are open
            local icon="  "
            if [[ "$has_kids" == "true" ]]; then
                if [[ $is_filtering -eq 1 || "$exp_str" == *"|$id|"* ]]; then
                    icon="▼ "
                else
                    icon="▶ "
                fi
            fi

            # 3. ROBUST DISABLED CHECK (The Fix)
            # We look up the tree in the master list to see if ANY ancestor is unchecked
            local is_disabled="false"
            local scan_ptr=$i
            local check_d=$depth
            while [[ $scan_ptr -gt 0 ]]; do
                ((scan_ptr--))
                local p_node="${all_nodes[$scan_ptr]}"
                local p_depth="${p_node%%|*}"
                if [[ $p_depth -lt $check_d ]]; then
                    local p_label="${p_node#*|*|}"; p_label="${p_label%%|*}"
                    if [[ "$p_label" == *"[ ]"* || "$p_label" == *"( )"* ]]; then
                        is_disabled="true"; break
                    fi
                    check_d=$p_depth
                fi
            done

            formatted_lines[${#formatted_lines[@]}]="${indent}${icon}${label}|${is_disabled:-false}"
        done
    }


    _update_tree_cache
    _init_tui

    while true; do
        _draw_header "$title" "$msg"
        
        if [[ "$ENABLE_FILTER" == "true" ]]; then
            _draw_at "$row"
            local f_style="${BG_WID_ESC}${FG_TEXT_ESC}"
            [[ $cur -eq -1 ]] && f_style="${BG_INPUT_ESC}${FG_BLUE_BOLD}"
            printf "  Filter: ${f_style} > %-25s ${RESET}${BG_MAIN_ESC}" "$filter_query" >&2
            _draw_line "" "$row"; _draw_line ""
        fi

        local view_top=$row
        local view_height=$(( MAX_HEIGHT - view_top - 2 ))
        [[ $view_height -lt 5 ]] && view_height=5
        local v_count=${#visible_indices[@]}

        # --- CRITICAL FIX 1: BOUNDS CLAMPING ---
        # Only clamp the list navigation if we aren't focused on the filter (-1)
        if [[ $cur -ge 0 ]]; then
            [[ $cur -ge $v_count ]] && cur=$((v_count - 1))
            [[ $cur -lt 0 ]] && cur=0
            # Viewport math
            [[ $cur -lt $top ]] && top=$cur
            [[ $cur -ge $((top + view_height)) ]] && top=$((cur - view_height + 1))
        fi

        for ((i=0; i<view_height; i++)); do
            local v_idx=$((top + i))
            local current_view_row=$((view_top + i))
            _draw_at "$current_view_row"
            printf "  " >&2
            
            if [[ $v_idx -lt $v_count ]]; then
                local is_cur=0; [[ $v_idx -eq $cur ]] && is_cur=1
                
                IFS='|' read -r content_line item_disabled <<< "${formatted_lines[$v_idx]}"
                
                local item_w=$box_width
                [[ "$content_line" == *"▶"* || "$content_line" == *"▼"* ]] && item_w=$(( box_width + 2 ))

                # THE PRIORITY FIX:
                # If the item is focused (is_cur=1), we draw it NORMALLY.
                # _draw_item will handle the blue HL_WHITE_BOLD style.
                # We only override the color if it is NOT focused AND disabled.
                if [[ "$item_disabled" == "true" && $is_cur -eq 0 ]]; then
                    local OLD_TEXT=$FG_TEXT_ESC
                    FG_TEXT_ESC=$FG_HINT_ESC
                    _draw_item "menu" "$is_cur" 0 "$content_line" "$item_w"
                    FG_TEXT_ESC=$OLD_TEXT
                else
                    _draw_item "menu" "$is_cur" 0 "$content_line" "$item_w"
                fi
            else
                # THE FIX: Clear the area exactly up to box_width + 2
                # We avoid using MAX_WIDTH here because it's what's causing 
                # the background to spill over by 1 char.
                local clear_w=$(( box_width + 2 ))
                printf "  %${clear_w}s" "" >&2
            fi
            _draw_line "" "$current_view_row"
        done

        row=$((view_top + view_height))
        _draw_line ""
        TOGGLE_CONTROLS=""
        ENTER_ACTION="Select"
        [[ "$mode" == "config" ]] && TOGGLE_CONTROLS="[Space] Toggle | "
        [[ "$mode" == "config" ]] && ENTER_ACTION="Confirm"
        _draw_controls " [Arrows] Move/Expand | ${TOGGLE_CONTROLS}[Enter] ${ENTER_ACTION}"
        _draw_footer

        # --- STEP 1: ATOMIC CAPTURE ---
        local key="" ESC_SEQ=""
        IFS= read -rsn1 key < /dev/tty
        [[ "$key" == $'\e' ]] && read -rsn2 ESC_SEQ < /dev/tty

        # --- STEP 2: FILTER INPUT (Focus at -1) ---
        if [[ "$ENABLE_FILTER" == "true" && $cur -eq -1 ]]; then
            if [[ -z "$ESC_SEQ" ]]; then
                case "$key" in
                    $'\177'|$'\b') filter_query="${filter_query%?}"; _update_tree_cache; continue ;;
                    "") # ENTER: JUMP TO MATCH
                        if [[ ${#visible_indices[@]} -gt 0 ]]; then
                            cur=0 # Fallback
                            shopt -s nocasematch
                            for ((idx=0; idx<${#visible_indices[@]}; idx++)); do
                                local g_idx=${visible_indices[$idx]}
                                local node="${all_nodes[$g_idx]}"
                                local rem="${node#*|}"
                                local id_str="${rem%%|*}"
                                local lab_str="${rem#*|}"; lab_str="${lab_str%%|*}"

                                if [[ "$lab_str" == *"$filter_query"* || "$id_str" == *"$filter_query"* ]]; then
                                    cur=$idx
                                    break
                                fi
                            done
                            shopt -u nocasematch
                        fi
                        # CRITICAL FIX: Jump to the top of the loop now
                        # This prevents the "List Navigation" Enter logic from running
                        continue 
                        ;;
                    *) 
                        # Capture printable chars
                        if [[ -n "$key" ]]; then
                            filter_query="${filter_query}${key}"
                            _update_tree_cache
                            # Force cur to -1 to stay in the input box
                            cur=-1
                            continue 
                        fi
                        ;;
                esac
            else
                # Down arrow moves to list
                [[ "$ESC_SEQ" == "[B" ]] && [[ $v_count -gt 0 ]] && cur=0
                continue
            fi
        fi

        # --- STEP 3: LIST NAVIGATION (Focus >= 0) ---
        if [[ -n "$ESC_SEQ" ]]; then
            local g_idx=${visible_indices[$cur]}
            local node="${all_nodes[$g_idx]}"
            local d="${node%%|*}"; local rest="${node#*|}"
            local id="${rest%%|*}"; rest="${rest#*|}"; local k="${rest##*|}"

            case "$ESC_SEQ" in
                "[A") if [[ $cur -gt 0 ]]; then ((cur--)); elif [[ "$ENABLE_FILTER" == "true" ]]; then cur=-1; fi ;;
                "[B") [[ $cur -lt $((v_count - 1)) ]] && ((cur++)) ;;
                "[C") [[ "$k" == "true" ]] && expanded+=("$id") && _update_tree_cache ;;
                "[D") # Collapse Logic
                    for i in "${!expanded[@]}"; do [[ "${expanded[$i]}" == "$id" ]] && unset 'expanded[$i]'; done
                    local scan_idx=$((g_idx + 1))
                    while [[ $scan_idx -lt $count ]]; do
                        local snode="${all_nodes[$scan_idx]}"
                        [[ "${snode%%|*}" -le $d ]] && break
                        local sid="${snode#*|}"; sid="${sid%%|*}"
                        for i in "${!expanded[@]}"; do [[ "${expanded[$i]}" == "$sid" ]] && unset 'expanded[$i]'; done
                        ((scan_idx++))
                    done
                    _update_tree_cache ;;
            esac
            continue
        fi

        case "$key" in
            $'\177'|$'\b') # Backspace Jump
                [[ "$ENABLE_FILTER" == "true" ]] && cur=-1 ;;
            " ") # Space Toggle
                local g_idx=${visible_indices[$cur]}
                local node="${all_nodes[$g_idx]}"
                local d="${node%%|*}"; local rest="${node#*|}"
                local id="${rest%%|*}"; rest="${rest#*|}"
                local l="${rest%%|*}"; local has_kids="${rest##*|}"

                # Check if parents are disabled
                local is_disabled=0; local scan_ptr=$g_idx; local target_d=$d
                while [[ $scan_ptr -gt 0 ]]; do
                    ((scan_ptr--))
                    local pnode="${all_nodes[$scan_ptr]}"
                    local pd="${pnode%%|*}"; local prest="${pnode#*|}"; local pl="${prest#*|}"
                    if [[ $pd -lt $target_d ]]; then
                        if [[ "$pl" == *"[ ]"* || "$pl" == *"( )"* ]]; then is_disabled=1; break; fi
                        target_d=$pd
                    fi
                done
                [[ $is_disabled -eq 1 ]] && continue

                if [[ "$l" == *"[ ]"* || "$l" == *"[x]"* ]]; then
                    if [[ "$l" == *"[ ]"* ]]; then l="${l/\[ \]/[x]}"
                    else
                        l="${l/\[x\]/[ ]}"
                        for ((j=g_idx+1; j<count; j++)); do
                            local cnode="${all_nodes[$j]}"
                            local cd="${cnode%%|*}"
                            [[ $cd -le $d ]] && break
                            local crest="${cnode#*|}"
                            local cid="${crest%%|*}"; crest="${crest#*|}"
                            local cl="${crest%%|*}"; local chk="${crest##*|}"
                            cl="${cl/\[x\]/[ ]}"; cl="${cl/\(\*\)/( )}"
                            all_nodes[$j]="$cd|$cid|$cl|$chk"
                        done
                    fi
                    all_nodes[$g_idx]="$d|$id|$l|$has_kids"
                elif [[ "$l" == *"( )"* || "$l" == *"(*)"* ]]; then
                     local scan=$g_idx; while [[ $scan -gt 0 ]]; do local sn="${all_nodes[$((scan-1))]}"; [[ ${sn%%|*} -lt $d ]] && break; ((scan--)); done
                     local end=$g_idx; while [[ $end -lt $((count-1)) ]]; do local en="${all_nodes[$((end+1))]}"; [[ ${en%%|*} -lt $d ]] && break; ((end++)); done
                     for ((j=scan; j<=end; j++)); do 
                        local tnode="${all_nodes[$j]}"
                        local td="${tnode%%|*}"; local trest="${tnode#*|}"
                        local tid="${trest%%|*}"; trest="${trest#*|}"
                        local tl="${trest%%|*}"; local tk="${trest##*|}"
                        [[ $td -eq $d ]] && tl="${tl/\(\*\)/( )}" && all_nodes[$j]="$td|$tid|$tl|$tk"
                     done
                     l="${l/\( \)/(*)}"
                     all_nodes[$g_idx]="$d|$id|$l|$has_kids"
                fi
                _update_tree_cache ;;
            "") # Enter (Select/Confirm)
                if [[ "$mode" == "select" ]]; then
                    local selection=${all_nodes[${visible_indices[$cur]}]}
                    local id_part="${selection#*|}"
                    TUI_RESULT="${id_part%%|*}"; echo "${TUI_RESULT}"; return 0
                else
                    TUI_RESULT="${all_nodes[@]}"; for n in "${all_nodes[@]}"; do echo "$n"; done; return 0
                fi ;;
            "q") return 1 ;;
        esac
    done
}


# Returns a single ID (Dialog style)
tree() {
    local t=$1 m=$2 d=0
    
    # Check if $3 is a number (initial index)
    if [[ "$3" =~ ^[0-9]+$ ]]; then
        d=$(($3 - 1))
        shift 3
    else
        # If not, the tree data nodes start at $3
        shift 2
    fi
    
    _tree_core "select" "$t" "$m" "$d" "$@"
}

# Returns generated Variable pairs
configtree() {
    local t=$1 m=$2 d=0
    
    # 1. Detect optional focused index
    if [[ "$3" =~ ^[0-9]+$ ]]; then
        d=$(($3 - 1))
        shift 3
    else
        shift 2
    fi

    local raw_data=()
    local old_ifs="$IFS"; IFS=$'\n'
    # 2. Pass $d into _tree_core (which we've updated to accept a focused index)
    raw_data=($(_tree_core "config" "$t" "$m" "$d" "$@"))
    IFS="$old_ifs"
    
    [[ ${#raw_data[@]} -eq 0 ]] && return 1

    # ... [rest of your loop logic remains exactly the same] ...
    local path_stack=()
    local skip_depth=-1
    local i node depth id label has_kids remaining

    for ((i=0; i<${#raw_data[@]}; i++)); do
        node="${raw_data[$i]}"
        
        # 2. Performance Fix: Native Parameter Expansion instead of 'read <<<'
        depth="${node%%|*}"
        remaining="${node#*|}"
        id="${remaining%%|*}"
        remaining="${remaining#*|}"
        label="${remaining%%|*}"
        # has_kids is rarely needed here but extracted for consistency
        has_kids="${remaining##*|}"
        
        # Omit children if parent was falsey
        [[ $skip_depth -ne -1 && $depth -gt $skip_depth ]] && continue
        skip_depth=-1

        # 3. Optimization: Clean the ID once before putting it on the stack
        # This prevents re-cleaning every segment in the nested 'j' loop
        local clean_id="${id//[-.]/_}"
        path_stack[$depth]="$clean_id"

        # Determine value (Fast string matching)
        local value=""
        case "$label" in
            # Using case is faster than [[ ... == ... ]] for multiple patterns
            *"[x]"*|*"(*)"*) value="true" ;;
            *"[ ]"*|*"( )"*) value="false" ;;
        esac

        if [[ -n "$value" ]]; then
            # 4. Generate variable name
            local var_name=""
            for ((j=0; j<=depth; j++)); do
                [[ -z "$var_name" ]] && var_name="${path_stack[$j]}" || var_name="${var_name}_${path_stack[$j]}"
            done
            
            echo "${var_name}=${value}"
            
            # If a parent is false, skip its children
            [[ "$value" == "false" ]] && skip_depth=$depth
        fi
    done
}

table() {
    local title=$1 src=$2 top=0 cur=$((${3:-0} - 1)) # Set initial focus
    local box_width=$(( MAX_WIDTH - 6 )) 
    local display_lines=() commands=() header_row=""
    
    [[ ! -f "$src" ]] && { msgbox "Error" "File not found: $src"; return 1; }

    # 1. Parse CSV
    local first=true
    local w1=$(( box_width * 33 / 100 ))
    local w2=$(( box_width * 26 / 100 ))
    local w3=$(( box_width - w1 - w2 - 2 ))
    
    while IFS=',' read -r c1 c2 c3 cmd; do
        local formatted=$(printf "%-${w1}s %-${w2}s %-${w3}s" "$c1" "$c2" "$c3")
        if [[ "$first" == "true" ]]; then
            header_row="$formatted"
            first=false
        else
            display_lines+=("$formatted")
            commands+=("$cmd")
        fi
    done < "$src"
    local count=${#display_lines[@]}
    
    _init_tui
    while true; do
        _draw_header "$title" "Table View: $src"

        # 2. DYNAMIC HEIGHT MATH
        local view_top=$row
        # Total lines available for the WHOLE table (Header + Data)
        local total_table_area=$(( MAX_HEIGHT - view_top - 2 ))
        # Data area is total minus the 1 line for the pinned header
        local data_height=$(( total_table_area - 1 ))
        [[ $data_height -lt 3 ]] && data_height=3

        # Viewport constraints based on DATA_HEIGHT
        [[ $cur -lt $top ]] && top=$cur
        [[ $cur -ge $((top + data_height)) ]] && top=$((cur - data_height + 1))

        # 3. Pinned Table Header
        _draw_at "$row"
        printf "  ${BG_TABLE_HEADER_ESC}${BOLD} %-${box_width}s ${RESET}${BG_MAIN_ESC}" "${header_row}" >&2
        local absolute_right_edge=$(( PADDING_LEFT + MAX_WIDTH ))
        printf "\e[${absolute_right_edge}G${RESET}" >&2
        ((row++))

        # 4. Scrollable Data Rows
        local data_start_row=$row
        for ((i=0; i<data_height; i++)); do
            local v_idx=$((top + i))
            local current_view_row=$((data_start_row + i))
            
            _draw_at "$current_view_row"
            printf "  " >&2 

            if [[ $v_idx -lt $count ]]; then
                local is_cur=0; [[ $v_idx -eq $cur ]] && is_cur=1
                _draw_item "text" "$is_cur" 0 "${display_lines[$v_idx]}" "$box_width"
            fi
            _draw_line "" "$current_view_row"
        done
        
        # 5. Footer (Starts exactly after the last data row)
        row=$((data_start_row + data_height))
        _draw_line "" 
        _draw_controls " [Arrows/jk] Scroll | [Enter] Select"
        _draw_footer

        # 6. Input Handling
        local key; IFS= read -rsn1 key < /dev/tty
        case "$key" in
            "j") [[ $cur -lt $((count - 1)) ]] && ((cur++)) ;;
            "k") [[ $cur -gt 0 ]] && ((cur--)) ;;
            "")  TUI_RESULT="${commands[$cur]}"; echo "${commands[$cur]}"; return 0 ;;
            $'\e') 
                read -rsn2 key
                case "$key" in
                    "[A") [[ $cur -gt 0 ]] && ((cur--)) ;;
                    "[B") [[ $cur -lt $((count - 1)) ]] && ((cur++)) ;;
                esac
                ;;
        esac
    done
}

filtertable() {
    local title=$1 src=$2 d=-1
    if [[ "$3" =~ ^[0-9]+$ ]]; then d=$(($3 - 1)); fi

    local filter_query="" last_query="INIT_STATE"
    local cur=$d top=0 box_width=$(( MAX_WIDTH - 6 ))
    
    [[ ! -f "$src" ]] && { msgbox "Error" "File not found: $src"; return 1; }

    local w1=$(( box_width * 33 / 100 ))
    local w2=$(( box_width * 26 / 100 ))
    local w3=$(( box_width - w1 - w2 - 2 ))

    # --- 2. Master Data Load (Preserve File Order) ---
    local master_lines=() master_cmds=() header_row=""
    local first=true
    while IFS=',' read -r c1 c2 c3 cmd; do
        local formatted=$(printf "%-${w1}s %-${w2}s %-${w3}s" "$c1" "$c2" "$c3")
        if [[ "$first" == "true" ]]; then
            header_row="$formatted"
            first=false
        else
            # Using += ensures sequential indexing (0, 1, 2...) in order of read
            master_lines+=("$formatted")
            master_cmds+=("$cmd")
        fi
    done < "$src"

    _init_tui
    while true; do
        # --- 3. Filtering (Maintain relative master order) ---
        if [[ "$filter_query" != "$last_query" ]]; then
            local filtered_lines=() filtered_cmds=()
            shopt -s nocasematch
            local i
            # Iterate through indices numerically to maintain file order
            for ((i=0; i<${#master_lines[@]}; i++)); do
                if [[ -z "$filter_query" || "${master_lines[i]}" == *"$filter_query"* ]]; then
                    filtered_lines+=("${master_lines[i]}")
                    filtered_cmds+=("${master_cmds[i]}")
                fi
            done
            shopt -u nocasematch
            count=${#filtered_lines[@]}
            last_query="$filter_query"
        fi

        # [Steps 4-6 remain exactly the same as your working version]
        _draw_header "$title" "Use the input below to filter results"
        _draw_at "$row"
        local search_style=$([[ $cur -eq -1 ]] && echo "${BG_INPUT_ESC}${FG_BLUE_BOLD}" || echo "${BG_WID_ESC}${FG_TEXT_ESC}")
        printf "  Filter: ${search_style} > %-25s ${RESET}" "$filter_query" >&2
        _draw_line "" "$row" 
        _draw_line "" 

        local view_top=$row
        local view_height=$(( MAX_HEIGHT - view_top - 2 ))
        [[ $view_height -lt 5 ]] && view_height=5
        
        _draw_at "$row"
        printf "  ${BG_TABLE_HEADER_ESC}${BOLD} %-${box_width}s ${RESET}" "${header_row}" >&2
        _draw_line "" "$row"
        
        local data_top=$row
        local data_height=$(( view_height - 1 ))

        [[ $cur -ge $count ]] && cur=$((count - 1))
        if [[ $cur -ge 0 ]]; then
            [[ $cur -lt $top ]] && top=$cur
            [[ $cur -ge $((top + data_height)) ]] && top=$((cur - data_height + 1))
        fi

        for ((i=0; i<data_height; i++)); do
            local v_idx=$((top + i))
            local current_view_row=$((data_top + i))
            _draw_at "$current_view_row"
            printf "  " >&2 

            if [[ $v_idx -lt $count ]]; then
                local is_cur=0; [[ $v_idx -eq $cur ]] && is_cur=1
                _draw_item "text" "$is_cur" 0 "${filtered_lines[$v_idx]}" "$box_width"
            else
                printf "%$((box_width + 2))s" "" >&2
            fi
            _draw_line "" "$current_view_row"
        done
        
        row=$((data_top + data_height))
        _draw_footer
        _draw_spacer
        _draw_controls " [Typing] Filter | [Arrows/jk] Scroll | [Enter] Select"

        # 7. Input Handling
        local key; IFS= read -rsn1 key < /dev/tty
        if [[ $key == $'\e' ]]; then
            read -rsn2 key
            case "$key" in
                "[A") [[ $cur -gt -1 ]] && ((cur--)) ;; 
                "[B") [[ $cur -lt $((count - 1)) ]] && ((cur++)) ;;
            esac
            continue
        fi

        case "$key" in
            "j") 
                if [[ $cur -ge 0 ]]; then [[ $cur -lt $((count - 1)) ]] && ((cur++))
                else filter_query="${filter_query}j"; cur=-1; top=0; fi ;;
            "k") 
                if [[ $cur -ge 0 ]]; then [[ $cur -gt -1 ]] && ((cur--))
                else filter_query="${filter_query}k"; cur=-1; top=0; fi ;;
            "") # Enter
                if [[ $cur -ge 0 ]]; then
                    # If in the table, select the item
                    if [[ $count -gt 0 ]]; then
                        TUI_RESULT="${filtered_cmds[$cur]}"
                        echo "${filtered_cmds[$cur]}"
                        return 0
                    fi
                else
                    # If in the input box, move to the first table item
                    [[ $count -gt 0 ]] && cur=0
                fi ;;
            $'\177'|$'\b') filter_query="${filter_query%?}"; cur=-1; top=0 ;;
            *) if [[ "$key" =~ [[:print:]] ]]; then filter_query="${filter_query}${key}"; cur=-1; top=0; fi ;;
        esac
    done
}

modal() {
    local BACKTITLE=
    
    # 1. Shadow BG_MAIN locally. 
    # Uses prefixed value if present, otherwise defaults to a dark/med grey
    # (slightly lighter than defatul $BG_MAIN)
    local BG_MAIN="50;50;50"

    # Allow overriding the modal background colour by setting BG_MODAL='255;0;0' (etc)
    if [[ ! -z "$BG_MODAL" ]];then
        BG_MAIN="$BG_MODAL"
    fi
    
    # 2. Re-calculate the escape sequence so sub-functions use the new color
    local BG_MAIN_ESC=$(_esc 50 "$BG_MAIN")

    # 3. Mode Logic
    local target_mode="$TUI_MODE"
    if [[ "$target_mode" == "fullscreen" || -z "$target_mode" ]]; then
        target_mode="centered"
    fi
    
    local old_mode="$TUI_MODE"
    local old_modal="$TUI_MODAL"
    
    TUI_MODE="$target_mode" 
    TUI_MODAL="true"

    stty sane; stty -echo

    eval "$1"

    # 4. Restore state
    TUI_MODE="$old_mode"
    TUI_MODAL="$old_modal"
    
    _init_tui 
}

mainmenu() {
    local title=$1 msg=$2 dsl=$3
    # --- STARTUP FOCUS FIX ---
    # If $4 is provided, subtract 1 to convert natural number to index.
    # If not provided, default to index 0.
    local cur_side=$(( ${4:-1} - 1 ))
    
    local initial_table_idx=$5
    local cur_table=-1
    local focus=0

    if [[ -n "$initial_table_idx" ]]; then
        cur_table=$((initial_table_idx - 1))
        focus=1
    fi
    
    # Ensure last_side is distinct from any possible cur_side on boot
    local last_side=-2 
    local last_query="INIT"
    local filter_query="" table_top=0 force_refilter=0

    # 1. Parse DSL (Pure Bash)
    local side_labels=() side_msgs=() side_files=()
    while IFS=':' read -r lab desc fil; do
        [[ -z "$lab" ]] && continue
        side_labels[${#side_labels[@]}]="$lab"
        side_msgs[${#side_msgs[@]}]="$desc"
        side_files[${#side_files[@]}]="$fil"
    done <<< "$dsl"
    local side_count=${#side_labels[@]}

    # Bounds check for initial side
    [[ $cur_side -ge $side_count ]] && cur_side=$((side_count - 1))
    [[ $cur_side -lt 0 ]] && cur_side=0

    TUI_MODE="fullscreen" 
    _init_tui 

    local side_w=$(( MAX_WIDTH * 25 / 100 ))
    local table_x=$(( side_w + 6 )) 
    local table_w=$(( MAX_WIDTH - table_x - 2 ))
    local absolute_table_x_esc="\e[$(( PADDING_LEFT + table_x ))G"

    while true; do
        # 3. DATA LOADER
        if [[ $cur_side -ne $last_side ]]; then
            local src="${side_files[$cur_side]}"
            master_lines=(); master_cmds=()
            
            if [[ -f "$src" ]]; then
                # Dynamic Width Calculation (Same as your optimized version)
                local widths=$(awk -F',' '{for(i=1;i<=3;i++){len=length($i);if(len>max[i])max[i]=len}}END{print max[1],max[2],max[3]}' "$src")
                read -r dw1 dw2 dw3 <<< "$widths"
                dw1=$((dw1 + 2)); dw2=$((dw2 + 2)); dw3=$((dw3 + 2))

                {
                    read -r header_row_raw
                    IFS=',' read -r c1 c2 c3 cmd <<< "$header_row_raw"
                    printf -v table_header "%-${dw1}s %-${dw2}s %-${dw3}s" "$c1" "$c2" "$c3"
                    while IFS=',' read -r c1 c2 c3 cmd; do
                        printf -v fmt "%-${dw1}s %-${dw2}s %-${dw3}s" "$c1" "$c2" "$c3"
                        master_lines[${#master_lines[@]}]="$fmt"
                        master_cmds[${#master_cmds[@]}]="$cmd"
                    done 
                } < "$src"
            fi
            
            # --- STARTUP RESET LOGIC ---
            # We ONLY reset the table focus if this is NOT the very first boot
            if [[ $last_side -ne -2 ]]; then
                filter_query=""
                cur_table=-1
                table_top=0
            fi
            
            last_side=$cur_side
            ((force_refilter++))
        fi

        # 4. CONDITIONAL FILTER
        if [[ "$filter_query" != "$last_query" || $force_refilter -gt 0 ]]; then
            filtered_lines=(); filtered_cmds=()
            search_pattern="*${filter_query}*"
            shopt -s nocasematch
            for i in "${!master_lines[@]}"; do
                if [[ -z "$filter_query" ]]; then
                    filtered_lines[${#filtered_lines[@]}]="${master_lines[i]}"
                    filtered_cmds[${#filtered_cmds[@]}]="${master_cmds[i]}"
                else
                    case "${master_lines[i]}" in
                        $search_pattern) 
                            filtered_lines[${#filtered_lines[@]}]="${master_lines[i]}"
                            filtered_cmds[${#filtered_cmds[@]}]="${master_cmds[i]}"
                            ;;
                    esac
                fi
            done
            shopt -u nocasematch
            f_count=${#filtered_lines[@]}
            
            # Final bounds check for table focus
            [[ $cur_table -ge $f_count ]] && cur_table=$((f_count - 1))
            
            last_query="$filter_query"; force_refilter=0
        fi

        # 5. RENDERING
        local frame=""
        row=$(_get_start_row)
        printf -v line "  ${FG_TEXT_ESC}=== %s ===${BG_MAIN_ESC}${CLR_EOL}" "$title"
        frame+="\e[${row};${PADDING_LEFT}H${BG_MAIN_ESC}${line}\n"
        ((row++))
        frame+="\e[${row};${PADDING_LEFT}H${BG_MAIN_ESC}  ${side_msgs[$cur_side]}${CLR_EOL}\n"
        ((row++)); ((row++))
        
        local list_top=$row
        local view_h=$(( MAX_HEIGHT - list_top - 2 ))
        local data_h=$(( view_h - 3 ))

        # --- VIEWPORT AUTO-ADJUST ---
        if [[ $cur_table -ge 0 ]]; then
            [[ $cur_table -lt $table_top ]] && table_top=$cur_table
            [[ $cur_table -ge $((table_top + data_h)) ]] && table_top=$((cur_table - data_h + 1))
        fi

        for ((i=0; i<view_h; i++)); do
            local draw_row=$((list_top + i))
            local row_content="\e[${draw_row};${PADDING_LEFT}H${BG_MAIN_ESC} "
            
            # Sidebar Item
            if [[ $i -lt $side_count ]]; then
                local style=$BG_WID_ESC
                if [[ $i -eq $cur_side ]]; then
                    [[ $focus -eq 0 ]] && style=$HL_WHITE_BOLD || style="${BG_WID_ESC}${BOLD}"
                fi
                printf -v item "${style} %-$((side_w - 2))s ${RESET}${BG_MAIN_ESC}" "${side_labels[$i]}"
                row_content+="$item"
            else 
                printf -v item "%${side_w}s" ""; row_content+="$item"
            fi

            row_content+="$absolute_table_x_esc"

            if [[ $i -eq 0 ]]; then
                local s_style=$BG_WID_ESC; [[ $focus -eq 1 && $cur_table -eq -1 ]] && s_style=$BG_INPUT_ESC
                local lbl_style=$([[ $focus -eq 1 && $cur_table -eq -1 ]] && echo "${FG_BLUE_BOLD}" || echo "${FG_TEXT_ESC}")
                printf -v item "${lbl_style}Filter: ${s_style}${lbl_style} > ${FG_INPUT_ESC}%-20s ${RESET}${BG_MAIN_ESC}" "$filter_query"
                row_content+="$item"
            elif [[ $i -eq 2 ]]; then
                printf -v item "${BG_TABLE_HEADER_ESC}${BOLD} %-${table_w}s ${RESET}${BG_MAIN_ESC}" "$table_header"
                row_content+="$item"
            elif [[ $i -ge 3 ]]; then
                local data_idx=$((i - 3 + table_top))
                if [[ $f_count -eq 0 ]]; then
                    if [[ $i -eq 3 ]]; then
                        row_content+="${FG_HINT_ESC}No matching items found...${RESET}${BG_MAIN_ESC}${CLR_EOL}"
                    else
                        row_content+="${BG_MAIN_ESC}${CLR_EOL}"
                    fi
                elif [[ $data_idx -lt $f_count ]]; then
                    local style=$BG_WID_ESC; [[ $data_idx -eq $cur_table && $focus -eq 1 ]] && style=$HL_WHITE_BOLD
                    printf -v item "${style} %-${table_w}s ${RESET}${BG_MAIN_ESC}${CLR_EOL}" "${filtered_lines[$data_idx]}"
                    row_content+="$item"
                else
                    row_content+="${CLR_EOL}"
                fi
            fi
            frame+="$row_content"
        done

        local footer_row=$((list_top + view_h + 1))
        frame+="\e[${footer_row};${PADDING_LEFT}H${FG_HINT_ESC} [Tab] Switch | [Arrows/jk] Nav | [Enter] Select | [q] Quit ${RESET}"

        LAST_FRAME="$frame"
        printf "%b" "$frame" >&2

        # 6. INPUT HANDLING (No subshells, using globbing over regex)
        local key; IFS= read -rsn1 key < /dev/tty
        [[ $key == $'\t' ]] && focus=$((1 - focus)) && continue
        
        if [[ $key == $'\e' ]]; then
            read -rsn2 key 
            case "$key" in
                "[A") [[ $focus -eq 0 ]] && { [[ $cur_side -gt 0 ]] && ((cur_side--)); } || { [[ $cur_table -gt -1 ]] && ((cur_table--)); } ;;
                "[B") [[ $focus -eq 0 ]] && { [[ $cur_side -lt $((side_count-1)) ]] && ((cur_side++)); } || { [[ $cur_table -lt $((f_count-1)) ]] && ((cur_table++)); } ;;
                "[C") focus=1; [[ $cur_table -lt 0 && $f_count -gt 0 ]] && cur_table=0 ;;
                "[D") focus=0 ;;
            esac
            continue
        fi

        case "$key" in
            "q") [[ $focus -eq 1 && $cur_table -eq -1 ]] && filter_query+="$key" || return 1 ;;
            "j") [[ $focus -eq 1 && $cur_table -eq -1 ]] && filter_query+="$key" || { [[ $focus -eq 0 ]] && { [[ $cur_side -lt $((side_count-1)) ]] && ((cur_side++)); } || { [[ $cur_table -lt $((f_count-1)) ]] && ((cur_table++)); }; } ;;
            "k") [[ $focus -eq 1 && $cur_table -eq -1 ]] && filter_query+="$key" || { [[ $focus -eq 0 ]] && { [[ $cur_side -gt 0 ]] && ((cur_side--)); } || { [[ $cur_table -gt -1 ]] && ((cur_table--)); }; } ;;
            "")  # Enter
                if [[ $focus -eq 0 ]]; then
                    focus=1; cur_table=-1
                elif [[ $cur_table -eq -1 ]]; then
                    [[ $f_count -gt 0 ]] && cur_table=0
                elif [[ $cur_table -ge 0 ]]; then
                    local cmd="${filtered_cmds[$cur_table]}"
                    if [[ "$cmd" == *"modal "* ]]; then
                        # 1. Execute Modal
                        eval "$cmd"
                        
                        # OPTIONAL: If the modal was a form, apply the variables immediately
                        [[ -n "$TUI_RESULT" && "$cmd" == *"form "* ]] && eval "$TUI_RESULT"

                        # 2. THE FIX: Flush the TTY buffer without using 'read -t'
                        # TCFLSH 0 flushes the input buffer (stdin)
                        # This works on macOS and Linux Bash 3.2
                        stty flush < /dev/tty 2>/dev/null || stty -echo echo
                        
                        # 3. Force a full UI refresh to wipe the modal artifacts
                        _init_tui
                    else
                        TUI_RESULT="$cmd"
                        return 0
                    fi
                fi ;;
            $'\177'|$'\b') [[ $focus -eq 1 ]] && { filter_query="${filter_query%?}"; cur_table=-1; } ;;
            *) [[ $focus -eq 1 && "$key" == [[:print:]] ]] && { filter_query+="$key"; cur_table=-1; } ;;
        esac
    done
}

_execute_mode_action() {
    local current_node="${raw_list[$cur]}"
    local current_path="${current_node%%|*}"
    local targets=""

    # 1. FORCE sync the local variable with the global prompt_buffer
    local cmd="$prompt_buffer"
    
    #msgbox "DEBUG" "Buffer was: [$cmd]"
    
    if [[ "$cmd" == cd\ * || "$cmd" == "cd.." ]]; then
        local target_dir="${cmd#cd }"
        [[ "$cmd" == "cd.." ]] && target_dir=".."

        # Handle '~' expansion safely for Bash 3.2
        if [[ "${target_dir:0:1}" == "~" ]]; then
            target_dir="${HOME}${target_dir:1}"
        fi

        # 3. ROBUST PATH RESOLUTION
        # Resolve against the TUI's root_dir, not the script's launch dir
        local resolved="$target_dir"
        [[ ! "$target_dir" == /* ]] && resolved="$root_dir/$target_dir"

        if [[ -d "$resolved" ]]; then
            # Update the global root_dir
            root_dir=$(cd "$resolved" && pwd)
            
            # Reset UI state and force a re-scan of the new folder
            ui_mode="NAV"
            prompt_buffer=""
            prompt_pos=0
            rebuild=1
            cur=0
            last_dir="FORCE_REBUILD" 
            return 0
        else
            msgbox "Error" "Directory not found: $target_dir"
            return 1
        fi
    fi

    # --- Standard Command Handling ---
    local tagged_count=0
    for item in "${selected_paths[@]}"; do
        if [[ "$item" != "0" && -n "$item" ]]; then
            targets+="'$item' "
            ((tagged_count++))
        fi
    done
    [[ $tagged_count -eq 0 ]] && targets="'$current_path'"

    case "$ui_mode" in
        "CMD"|"SUDO_CMD")
            local final_cmd="${prompt_buffer//\{\}/$targets}"
            final_cmd="${final_cmd//sel/$targets}"
            
            # 1. Create a temporary file to capture output
            local out_tmp="/tmp/tui_out_$$.txt"
            
            if [[ "$ui_mode" == "SUDO_CMD" ]]; then
                # Run sudo and capture BOTH stdout and stderr to the temp file
                # Use 'tee' so the user sees output in real-time
                sudo sh -c "cd '$root_dir' && $final_cmd" 2>&1 | tee "$out_tmp"
            else
                # Run standard command and capture output
                ( cd "$root_dir" && eval "$final_cmd" ) 2>&1 | tee "$out_tmp"
            fi

            # 2. Check if the file is NOT empty
            if [[ -s "$out_tmp" ]]; then
                # Output found: Show the "[Done]" prompt
                printf "\n\e[2m[Done] Press any key...\e[0m" >&2
                # Use standard read for portability
                read -rsn1 _ < /dev/tty
            fi

            # 3. Clean up and restore TUI
            rm -f "$out_tmp"
            stty -echo
            _init_tui
            _hide_cursor
            prompt_buffer=""; prompt_pos=0; rebuild=1
            ;;

        "RENAME")
            new_path="$root_dir/$prompt_buffer"
            mv "$current_path" "$new_path"
            
            # --- THE FIX: Make focus follow the renamed file ---
            last_path="$new_path"
            cur=-2
            
            ui_mode="NAV"
            selected_paths=()
            ;;
        "NEW_F")
            new_path="$root_dir/$prompt_buffer"
            # Use touch to create the file
            touch "$new_path"
            # Set this so the sidebar snaps focus to the new file
            last_path="$new_path"
            cur=-2
            ;;
        "NEW_D")
            new_path="$root_dir/$prompt_buffer"
            # Create directory
            mkdir -p "$new_path"
            last_path="$new_path"
            cur=-2
            ;;
    esac
}

_handle_paste() {
    # If clipboard is empty, do nothing
    [[ ${#clipboard_list[@]} -eq 0 ]] && return

    for item in "${clipboard_list[@]}"; do
        local name="${item##*/}"
        local target="$root_dir/$name"
        
        # Smart Rename (_1, _2)
        if [[ -e "$target" ]]; then
            local base="${name%.*}"
            local ext="${name##*.}"
            [[ "$base" == "$ext" ]] && ext="" || ext=".$ext"
            local i=1
            while [[ -e "$root_dir/${base}_$i$ext" ]]; do ((i++)); done
            target="$root_dir/${base}_$i$ext"
        fi

        if [[ "$clipboard_op" == "CUT" ]]; then
            mv -f "$item" "$target"
        else
            cp -rf "$item" "$target"
        fi
    done
    
    # Only clear clipboard if it was a CUT operation
    [[ "$clipboard_op" == "CUT" ]] && clipboard_list=()
    rebuild=1
}

_execute_sudo_with_pass() {
    # 1. Build the selection list
    local target_list=""
    for ((idx=0; idx<count; idx++)); do
        [[ "${selected_paths[$idx]}" -eq 1 ]] && target_list+="'${raw_list[$idx]%%|*}' "
    done
    [[ -z "$target_list" ]] && target_list="'${raw_list[$cur]%%|*}'"

    # 2. Replace placeholders in the saved cmd
    local cmd="${pending_sudo_cmd//\{\}/$target_list}"
    cmd="${cmd//sel/$target_list}"

    # 3. Pipe password to sudo
    echo "$prompt_buffer" | sudo -S -p '' sh -c "$cmd" > /dev/null 2>&1
    
    # 4. Clean up
    prompt_buffer=""; pending_sudo_cmd=""; prompt_pos=0; rebuild=1
}

_draw_prompt_only() {
    # Move to the fixed header row (usually PADDING_TOP + 1)
    local prompt_row=$(( PADDING_TOP + 1 ))
    
    # Move cursor, clear line from cursor to end, and print BG_MAIN to keep box solid
    # \e[K is the secret: it clears just to the end of the line, preventing flicker
    printf "\e[${prompt_row};${PADDING_LEFT}H${BG_MAIN_ESC}${CLR_EOL}" >&2
    
    # Re-run just the header message logic
    _draw_header "$title" "$header_msg"
    
    # Reposition physical cursor for typing
    local offset=4
    [[ "$ui_mode" == "CMD" || "$ui_mode" == "SUDO_CMD" ]] && offset=3
    printf "\e[${prompt_row};$(( PADDING_LEFT + offset + prompt_pos ))H" >&2
}

_get_prompt_msg() {
    local black_bg="${BG_INPUT_ESC}"
    local white_fg="\e[1;37m"
    local blue_fg="\e[1;38;2;${FG_INPUT}m"
    local red_fg="\e[1;38;2;${FG_INPUT_ROOT}m"
    local prompt_fg="$blue_fg"
    
    case "$ui_mode" in
        "CMD")       symbol=" $ ";        content="$prompt_buffer" ;; 
        "SUDO_CMD")  symbol=" # ";        content="$prompt_buffer" ;; 
        "SEARCH")    symbol="Search: > "; content=" $search_query" ;; 
        "RENAME")    symbol="Rename: ";   content=" $prompt_buffer" ;; 
        "NEW_F")     symbol="File name: ";     content=" $prompt_buffer" ;; 
        "NEW_D")     symbol="Dir name: ";      content=" $prompt_buffer" ;; 
    esac

    local total_w=$(( MAX_WIDTH - 4 ))
    
    if [[ "$ui_mode" == "CMD" || "$ui_mode" == "SUDO_CMD" ]]; then
        if [[ "$ui_mode" == "SUDO_CMD" ]]; then
            prompt_fg="$red_fg"
        fi
        # Blue "$" or red "#" symbol on Black BG with leading space
        local colored_sym="${prompt_fg}${symbol}${white_fg}"
        printf -v header_msg "${black_bg}${colored_sym}%-$((total_w - ${#symbol}))s${RESET}${BG_MAIN_ESC}" "$content"
    else
        # Grey symbol, then Black BG for content with leading space
        local fill_w=$(( total_w - ${#symbol} ))
        printf -v header_msg "${symbol}${black_bg}${white_fg}%-${fill_w}s${RESET}${BG_MAIN_ESC}" "$content"
    fi
}

_refresh_prompt() {
    _get_prompt_msg

    # Dynamically find the row where the "message/path" area starts
    # We use a local to protect the global row counter
    local -i p_row=$(( PADDING_TOP + $(_get_start_row) + 1))
    
    # In fullscreen, _get_start_row usually points to the line 
    # under the title. If that's still too high for your layout,
    # your +1 offset for fullscreen is the correct "tin-standard" fix.
    # [[ "$TUI_MODE" == "fullscreen" ]] && ((p_row++))    
    printf "\e[${p_row};${PADDING_LEFT}H${BG_MAIN_ESC}  %b" "$header_msg" >&2
    
    local sym_len=2
    case "$ui_mode" in
        "CMD"|"SUDO_CMD") sym_len=3 ;;
        "SEARCH")         sym_len=11 ;;
        "RENAME")         sym_len=9 ;;
        "NEW_F")          sym_len=12 ;;
        "NEW_D")          sym_len=11 ;;
    esac
    
    printf "\e[${p_row};$(( PADDING_LEFT + 2 + sym_len + prompt_pos ))H" >&2
    _show_cursor
}

_refresh_sidebar_only() {
    local clean_query="${search_query# }" # Strip leading UI space
    local filtered=() f_idx=0
    
    shopt -s nocasematch
    for item in "${master_raw_list[@]}"; do
        local name="${item#*|}"
        name="${name%|*}"
        # Match using glob (FAST in 3.2)
        # Bypass filter for '..'
        if [[ "$name" == ".." ]] || [[ -z "$clean_query" || "$name" == *"$clean_query"* ]]; then
            filtered[f_idx]="$item"
            ((f_idx++))
        fi
    done
    shopt -u nocasematch

    raw_list=("${filtered[@]}")
    count=${#raw_list[@]}
    cur=0; top=0

    # 3. Geometry: Use the dynamic anchor
    # Default offset from the content start
    local list_offset=4
    
    # The Fix: If we are in fullscreen and have a backtitle, 
    # we must push the origin down by 1 to align with the initial draw.
    if [[ "$TUI_MODE" == "fullscreen" && -n "$BACKTITLE" ]]; then
        ((list_offset++))
    fi

    # Calculate actual terminal row based on _get_start_row base
    local list_top=$(( PADDING_TOP + $(_get_start_row) + list_offset ))
    
    local height=$(( MAX_HEIGHT - (list_top - PADDING_TOP) + 1 ))
    [[ $height -lt 5 ]] && height=5 

    # 4. Rendering Loop: Surgical line updates
    for ((i=0; i<height; i++)); do
        local v_idx=$((top + i))
        local current_row=$((list_top + i))
        
        # Move to absolute row and clear with Main BG before drawing
        printf "\e[${current_row};${PADDING_LEFT}H${BG_MAIN_ESC}  " >&2
        
        if [[ $v_idx -lt $count ]]; then
            local node="${raw_list[$v_idx]}"
            local path="${node%%|*}"
            local remain="${node#*|}"
            local label="${remain%|*}"
            local is_dir="${remain##*|}"
            
            # Style logic: Focus stays on the top result while filtering
            local is_cur=0; [[ $v_idx -eq $cur ]] && is_cur=1
            local style=$BG_WID_ESC
            [[ $is_cur -eq 1 ]] && style=$HL_WHITE_BOLD
            
            # Color logic
            local color=$FG_TEXT_ESC
            if [[ "$is_dir" == "true" ]]; then
                color="\e[1;34m" # Bold Blue
            elif [[ -x "$path" ]]; then
                color="\e[1;32m" # Bold Green
            elif [[ "${label:0:1}" == "." ]]; then
                color="\e[2m"   # Faint
            fi

            # Print the item truncated to menu_w to maintain the box layout
            printf "${style}${color} %-${menu_w}s ${RESET}${BG_MAIN_ESC}" "${label:0:$menu_w}" >&2
        else
            # Clear empty rows below the filtered results
            printf "%$((menu_w + 2))s" "" >&2
        fi
    done
}

_update_display_path() {
    display_path="$root_dir"
    # Home replacement
    [[ "$display_path" == "$HOME"* ]] && display_path="~${display_path#$HOME}"

    local filter_suffix=""
    # Use the search_query variable. 
    # If your search query has the leading UI space, strip it.
    local clean_q="${search_query# }"
    if [[ -n "$clean_q" ]]; then
        filter_suffix=" (Filter: $clean_q)"
    fi
    
    # Calculate width and truncate as we did before...
    local avail_w=$(( MAX_WIDTH - 10 - ${#filter_suffix} ))
    [[ $avail_w -lt 10 ]] && avail_w=10

    if [[ ${#display_path} -gt $avail_w ]]; then
        local offset=$(( ${#display_path} - avail_w + 3 ))
        display_path="...${display_path:$offset}"
    fi
    
    # Set the global header_msg
    header_msg="Path: ${display_path}${filter_suffix}"
}

_get_tab_completion() {
    local current_input="$prompt_buffer"
    local prefix="" last_word=""
    
    # 1. Split command into prefix (cd ) and the word being completed (dir/foo)
    if [[ "$current_input" == *" "* ]]; then
        prefix="${current_input% *} "
        last_word="${current_input##* }"
    else
        prefix=""
        last_word="$current_input"
    fi

    # --- THE FIX FOR #3: FORCE RESET ON NEW PATH INPUT ---
    # If the user typed anything after the last completion (like a '/' or 'f')
    # and it no longer matches the cycle, we reset the index.
    if [[ -n "$last_completion_base" && "$current_input" != "$last_completion_base" ]]; then
        completion_idx=-1
    fi

    # --- RESET CYCLE ON NEW DEPTH ---
    # If the user just added a "/", reset cycling to scan the new subfolder
    if [[ "$current_input" == */ ]]; then
        completion_idx=-1
    fi

    # --- CYCLING LOGIC ---
    if [[ $completion_idx -ge 0 && "$current_input" == "$last_completion_base"* ]]; then
        ((completion_idx++))
        [[ $completion_idx -ge ${#completion_matches[@]} ]] && completion_idx=0
        
        prompt_buffer="${prefix}${completion_matches[$completion_idx]}"
        prompt_pos=${#prompt_buffer}
        last_completion_base="$prompt_buffer"
        return
    fi

    # --- PATH-AWARE SEARCH ---
    completion_matches=()
    completion_idx=-1
    
    local dir_part="" partial=""
    if [[ "$last_word" == *"/"* ]]; then
        # Capture everything up to and including the LAST slash
        dir_part="${last_word%/*}/"
        # Capture everything AFTER the last slash
        partial="${last_word##*/}"
    else
        dir_part=""
        partial="$last_word"
    fi

    # Resolve scan directory
    local scan_root="$root_dir"
    [[ "$dir_part" == /* ]] && scan_root="" 
    local real_scan_dir=$(cd "${scan_root}/${dir_part}" 2>/dev/null && pwd)
    
    if [[ -d "$real_scan_dir" ]]; then
        shopt -s dotglob nocaseglob
        # Match pattern
        local pattern="$real_scan_dir/${partial}*"
        
        # 1. Loop Dirs First
        for f in $pattern; do
            [[ ! -d "$f" ]] && continue
            local name="${f##*/}"
            [[ "$name" == "." || "$name" == ".." ]] && continue
            completion_matches[${#completion_matches[@]}]="${dir_part}${name}"
        done
        
        # 2. Loop Files Second
        for f in $pattern; do
            [[ ! -f "$f" ]] && continue
            local name="${f##*/}"
            completion_matches[${#completion_matches[@]}]="${dir_part}${name}"
        done
        shopt -u dotglob nocaseglob
    fi

    # --- APPLY FIRST MATCH ---
    if [[ ${#completion_matches[@]} -gt 0 ]]; then
        completion_idx=0
        prompt_buffer="${prefix}${completion_matches[0]}"
        prompt_pos=${#prompt_buffer}
        last_completion_base="$prompt_buffer"
    else
        printf "\a" >&2
    fi
}

file_manager() {
    local show_help=0
    local show_details=0
    local cmd_history=()
    local hist_ptr=-1
    local completion_matches=()
    local completion_idx=-1
    local last_completion_base=""
    local show_ignored=0  # 0 = hide, 1 = show

    local help_file="/tmp/tui_help_$$.txt"
    cat << EOF > "$help_file"
[Arrows]  Navigate
[ENTER]   Open / Select
[TAB]     Toggle selection (sel/{})
[.]       Toggle hidden files
[,]       Toggle detailed list
[i]       Toggle ignored (.gitignore)
[/]       Search filter
[:/!]     Shell prompt (! for root)
[sel/{}]  Current selection in prompt
[e]       Edit file in \$EDITOR
[f/d]     New file or dir
[r]       Rename item
[x/c/v]   Cut/copy/paste
[h/j/k/l] Left/down/up/right (vim)
[J/K/g/G] PageDown/PageUp/top/bottom
[q/ESC]   Exit / Cancel
EOF

    # Ensure the file is removed when the widget exits
    trap "rm -f '$help_file'; cleanup" EXIT

    # 1. SETUP & STATE
    local title=$1 root_dir=${2:-.}
    local cur=${3:-0} top=0 menu_w=30 
    local preview_x=$(( menu_w + 8 )) 
    local preview_offset=0
    local last_cur=-1 last_dir="INIT" rebuild=1
    local prompt_pos=0

    # Mode State: NAV (default), CMD (!), SEARCH (/), RENAME (r), NEW_F (f), NEW_D (d)
    local ui_mode="NAV"
    local prompt_buffer=""
    local clipboard_list=()
    local clipboard_op="" # "CUT" or "COPY"
    local search_query=""
    local selected_paths=()
    
    local dir_col="\e[1;34m" hid_col="\e[2m" exe_col="\e[1;32m"
    root_dir=$(cd "$root_dir" && pwd)

    while true; do
        # 2. DATA REBUILD
        if [[ "$root_dir" != "$last_dir" || $rebuild -eq 1 ]]; then
            raw_list=(); detail_list=() 
            [[ "$root_dir" != "$last_dir" ]] && selected_paths=()

            # --- THE FINAL SURGICAL FIX: IGNORE CACHE ---
            local ignored_cache="|"
            if [[ $show_ignored -eq 0 ]]; then
                if type git >/dev/null 2>&1; then
                    # We use 'ls -A1' to get EVERYTHING (hidden and visible)
                    # and pipe it into 'git check-ignore --stdin'
                    # This is the most accurate way to ask Git: "Of these files, what is ignored?"
                    local raw_ignored
                    raw_ignored=$(cd "$root_dir" && ls -A1 2>/dev/null | git check-ignore --stdin 2>/dev/null)
                    
                    if [[ -n "$raw_ignored" ]]; then
                        # Safe conversion to pipe-delimited string
                        local old_ifs="$IFS"; IFS=$'\n'
                        for line in $raw_ignored; do
                            # Strip any trailing slashes Git might add to directories
                            local clean_name="${line%/}"
                            ignored_cache="${ignored_cache}${clean_name}|"
                        done
                        IFS="$old_ifs"
                    fi
                fi
            fi

            # --- PRO MOVE: Fetch all metadata in ONE fork ---
            if [[ $show_details -eq 1 ]]; then
                # Fetch metadata for visible and hidden files
                while read -r v1 v2 v3 v4 v5 v6 v7 v8 name; do
                    [[ "$v1" == "total" || -z "$name" ]] && continue
                    [[ ${#v1} -eq 10 ]] && v1="${v1} "
                    [[ ${#v6} -eq 1 ]] && v6=" $v6"
                    local v8_aligned; printf -v v8_aligned "%5s" "$v8"
                    local clean_name="${name##*/}"
                    [[ "$clean_name" == "." || "$clean_name" == ".." ]] && continue
                    local safe_name="${clean_name//[^a-zA-Z0-9_]/_}"
                    printf -v "META_F_$safe_name" "%s %s %s %5s %s %s %s" \
                        "$v1" "$v3" "$v4" "$v5" "$v6" "$v7" "$v8_aligned"
                done < <(cd "$root_dir" && \ls -lAnhd * .* 2>/dev/null)
            fi

            # 1. Add Parent Dir
            if [[ "$root_dir" != "/" ]]; then
                raw_list[0]="${root_dir%/*}|..|true"
                selected_paths[0]=0
            fi

            shopt -s dotglob nocaseglob
            for type in "dirs" "files"; do
                for path in "$root_dir"/*; do
                    [[ ! -e "$path" ]] && continue
                    [[ "$type" == "dirs" && ! -d "$path" ]] && continue
                    [[ "$type" == "files" && ! -f "$path" ]] && continue

                    local name="${path##*/}"
                    [[ "$name" == "." || "$name" == ".." ]] && continue
                    [[ $show_hidden -eq 0 && "${name:0:1}" == "." ]] && continue
                    
                    # 2. THE FIX: Compare against our surgical cache
                    # If ignored_cache is only "|", this check will safely fail (correct)
                    if [[ $show_ignored -eq 0 && ${#ignored_cache} -gt 1 ]]; then
                        if [[ "$ignored_cache" == *"|$name|"* ]]; then
                            continue
                        fi
                    fi

                    if [[ -n "$search_query" ]]; then
                        # Note: In Bash 3.2, tr is fine, but this spawns a process per file
                        # Consider using case "$name" in *"${search_query# }"*) ;; for speed
                        local l_name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
                        [[ ! "$l_name" == *"$l_query"* ]] && continue
                    fi
                    
                    local idx=${#raw_list[@]}
                    local is_dir="false"; [[ -d "$path" ]] && is_dir="true"
                    raw_list[$idx]="$path|$name|$is_dir"
                    selected_paths[$idx]=0
                    
                    # --- THE INSTANT LOOKUP ---
                    if [[ $show_details -eq 1 ]]; then
                        # FIX 3: Must generate the SAME safe key used above
                        local safe_lookup="${name//[^a-zA-Z0-9_]/_}"
                        local varname="META_F_$safe_lookup"
                        
                        # Indirect expansion to grab the pre-calculated string
                        detail_list[$idx]="${!varname}"
                        # IMPORTANT: Do NOT 'unset' here, so 'files' pass can find them
                    fi
                done
            done
            shopt -u dotglob nocaseglob
            # --- CLEANUP (Optional): Remove the temporary variables to free memory ---
            if [[ $show_details -eq 1 ]]; then
                # Only if you are worried about RAM with thousands of files
                # unset ${!META_F_*} # Works in Bash 3.0+
                :
            fi
            
            count=${#raw_list[@]}
            master_raw_list=("${raw_list[@]}") # Always keep a full copy
            
            # --- THE FIX: Re-apply filter if search_query is active ---
            if [[ -n "$search_query" ]]; then
                _refresh_sidebar_only
                # _refresh_sidebar_only sets rebuild=0 and handles the draw, 
                # but since we are inside a rebuild block, we just want the data.
            fi

            # 5. Maintain focus logic
            if [[ $cur -eq -2 ]]; then
                cur=0 # Default fallback
                for ((idx=0; idx<count; idx++)); do
                    # Compare absolute paths
                    if [[ "${raw_list[$idx]%%|*}" == "$last_path" ]]; then
                        cur=$idx
                        break
                    fi
                done
            elif [[ -n "$search_query" ]]; then
                cur=0
            fi
            [[ $cur -ge $count ]] && cur=$((count - 1))
            [[ $cur -lt 0 ]] && cur=0

            _update_display_path
            
            last_dir="$root_dir"; rebuild=0; 
            
            _init_tui # This clears the screen
            
            # NOW: Explicitly draw the header with the msg we just updated
            _draw_header "$title" "$header_msg"
        fi

        # Construct the final header string
        local header_msg="Path: ${display_path}${filter_suffix}"

        case "$ui_mode" in
            "CMD"|"SUDO_CMD")
                local sym="$ "; [[ "$ui_mode" == "SUDO_CMD" ]] && sym="# "
                local fill_w=$(( MAX_WIDTH - 4 ))
                printf -v header_msg "${BG_INPUT_ESC}\e[1;37m%-${fill_w}s${RESET}${BG_MAIN_ESC}" "${sym}${prompt_buffer}"
                ;;
            "SEARCH"|"RENAME"|"NEW_F"|"NEW_D")
                local sym="Search: > "; [[ "$ui_mode" == "RENAME" ]] && sym="Rename: "
                [[ "$ui_mode" == "NEW_F" ]] && sym="File name: "; [[ "$ui_mode" == "NEW_D" ]] && sym="Dir name: "
                local fill_w=$(( MAX_WIDTH - 4 - ${#sym} ))
                printf -v header_msg "${sym}${BG_INPUT_ESC}\e[1;37m%-${fill_w}s${RESET}${BG_MAIN_ESC}" "$prompt_buffer"
                ;;
            "SUDO_PASS") 
                local masked="${prompt_buffer//?/*}"
                header_msg="${FG_INPUT_ROOT}Password: > ${masked}${RESET}" ;;
        esac

        if [[ "$ui_mode" == "NAV" ]]; then
            _draw_header "$title" "Path: $display_path"
        else
            # 1. Manually draw ONLY the Title line (Row 1)
            local title_row=$(( PADDING_TOP + 2 ))
            _draw_header "$title" "Path: $display_path"
            # printf "\e[${title_row};${PADDING_LEFT}H${BG_MAIN_ESC}  ${FG_TEXT_ESC}=== %s ===${RESET}${BG_MAIN_ESC}${CLR_EOL}" "$title" >&2
            
            # 2. Let the surgical redraw handle the Prompt line (Row 3)
            _refresh_prompt
        fi

        # Position physical cursor for the prompt
        if [[ "$ui_mode" != "NAV" ]]; then
            # Header row is PADDING_TOP + _get_start_row
            local prompt_row=$(( PADDING_TOP + 1 )) 
            # Calculate offset: "Path: " or "$ " length
            local offset=4 
            [[ "$ui_mode" == "CMD" || "$ui_mode" == "SUDO_CMD" ]] && offset=2
            printf "\e[${prompt_row};$(( PADDING_LEFT + offset + prompt_pos ))H" >&2
            _show_cursor
        fi

        # 4. SIDEBAR RENDER
        local list_top=$row
        
        # --- FIX 1: SIDEBAR WIDTH LOGIC ---
        # Only widen if details are ON AND help is OFF.
        local active_menu_w=$menu_w
        if [[ $show_details -eq 1 && $show_help -eq 0 ]]; then
            active_menu_w=$(( MAX_WIDTH - 6 ))
        fi

        # --- NEW: Dynamic Filename Column Width ---
        # Default for normal view (truncate if needed)
        local active_name_w=30

        local height=$(( MAX_HEIGHT - list_top - 2 ))
        [[ $cur -lt $top ]] && top=$cur
        [[ $cur -ge $((top + height)) ]] && top=$((cur - height + 1))

        for ((i=0; i<height; i++)); do
            local v_idx=$((top + i))
            local current_row=$((list_top + i))
            _draw_at "$current_row"
            printf "  " >&2 

            # --- FIX 2: FULL-SCREEN HELP SAFETY ---
            if [[ $show_help -eq 1 && $show_details -eq 1 ]]; then
                : # Skip drawing sidebar so help screen has exclusive control
            elif [[ $v_idx -lt $count ]]; then
                local node="${raw_list[$v_idx]}"
                local path="${node%%|*}"
                local remain="${node#*|}"
                local label="${remain%|*}"
                local is_dir="${remain##*|}"
                local is_cur=0; [[ $v_idx -eq $cur ]] && is_cur=1
                
                # --- FIX 3: PATH-BASED TAGGING ---
                local is_tag=0
                for s_path in "${selected_paths[@]}"; do
                    [[ "$s_path" == "$path" ]] && is_tag=1 && break
                done

                local display_name="$label"
                if [[ $show_details -eq 1 ]]; then
                    if [[ "$label" == ".." ]]; then
                        display_name=".."
                        [[ "$TUI_MODE" == "fullscreen" ]] && active_name_w=80
                    else
                        # --- FIX: Add / to directory labels in detailed view ---
                        local lbl="$label"
                        [[ "$is_dir" == "true" ]] && lbl="${label}/"
                        
                        local short_name="${lbl:0:$active_name_w}"
                        printf -v display_name "%-${active_name_w}s %s" "$short_name" "${detail_list[$v_idx]}"
                     fi
                else
                    # --- FIX: Add / to directory labels in normal view ---
                    [[ "$is_dir" == "true" && "$label" != ".." ]] && display_name="${label}/"
                fi

                # --- THE CRITICAL RENDERING FIX ---
                # We must ensure the style and color are applied CLEANLY
                # and that the substring calculation doesn't include hidden ANSI codes
                local visible_name="${display_name:0:$active_menu_w}"

                local style="" color=""
                
                if [[ $is_cur -eq 1 ]]; then
                    # FOCUS: Blue BG / White Text (Active cursor)
                    style="$HL_WHITE_BOLD"
                    color="" 
                elif [[ $is_tag -eq 1 ]]; then
                    # TAGGED: Standard BG / Bold Yellow Text
                    # We use \e[1;33m for Bold Yellow foreground
                    style="${BG_WID_ESC}"
                    color="\e[1;33m"
                else
                    # STANDARD: Common LS_COLORS emulation
                    style="${BG_WID_ESC}"
                    if [[ "$is_dir" == "true" ]]; then
                        color="\e[1;34m" # Bold Blue
                    elif [[ -x "$path" ]]; then
                        color="\e[1;32m" # Bold Green
                    elif [[ "$label" == .* ]]; then
                        color="\e[2m"   # Faint (Hidden)
                    else
                        color="$FG_TEXT_ESC"
                    fi
                fi

                local is_in_clipboard=0
                for cb_item in "${clipboard_list[@]}"; do
                    [[ "$cb_item" == "$path" ]] && is_in_clipboard=1 && break
                done

                local extra_style=""
                # \e[3m is Italic, \e[2m is Faint (Grey)
                [[ $is_in_clipboard -eq 1 ]] && extra_style="\e[3;2m" 

                # Apply to printf (Note: color is empty for clipboard items to ensure grey stays)
                local final_color="$color"
                [[ $is_in_clipboard -eq 1 ]] && final_color="" 

                # Apply extra_style to the printf
                printf "${style}${extra_style}${color} %-${active_menu_w}s ${RESET}${BG_MAIN_ESC}" "${display_name:0:$active_menu_w}" >&2
            else
                printf "%$((active_menu_w + 2))s" "" >&2
            fi
            _draw_line "" "$current_row"
        done

        # 5. PREVIEW OR HELP
        if [[ $show_help -eq 1 ]]; then
            # --- THE FLICKER PREVENTION FIX ---
            # Only run the wipe and preview if we haven't locked the help screen yet
            if [[ $last_cur -ne -3 ]]; then
                # 1. DYNAMIC WIPE
                local wipe_x=$preview_x
                local total_wipe_w=$(( MAX_WIDTH - preview_x - 1 ))
                
                if [[ $show_details -eq 1 ]]; then
                    wipe_x=2
                    total_wipe_w=$(( MAX_WIDTH - 4 ))
                fi

                # 2. THE CLEAN SLATE
                local h_row=$list_top
                while [[ $h_row -lt $((list_top + height)) ]]; do
                    _draw_at "$h_row" "$wipe_x"
                    printf "%${total_wipe_w}s" "" >&2
                    ((h_row++))
                done

                # 3. DRAW HELP
                local help_x=$preview_x
                [[ $show_details -eq 1 ]] && help_x=4
                preview "$help_file" "$list_top" "$height" "$help_x" 0

                # LOCK STATE: Set to -3 so navigation doesn't trigger a re-draw
                last_cur=-3
            fi
        elif [[ $show_details -eq 0 && "$ui_mode" == "NAV" ]]; then
            # Standard preview only runs if help is OFF
            if [[ $cur -ne $last_cur ]]; then
                local node="${raw_list[$cur]}"
                local p="${node%%|*}"
                
                # Ensure we have a temp file for the directory listing
                local preview_file="/tmp/tui_pv_$$.txt"

                if [[ "${node##*|}" == "false" ]]; then
                    # FILE: Standard preview
                    preview "$p" "$list_top" "$height" "$preview_x" "$preview_offset"
                else
                    # DIRECTORY: Ranger-style "Peek" inside
                    # -1 (one column), -A (all except . ..), -p (slash on dirs)
                    # We use head -20 because some head versions don't like -n
                    # 1. List dirs only (those ending in /) then files (everything else)
                    { ls -1Ap "$p" | grep '/$'; ls -1Ap "$p" | grep -v '/$'; } 2>/dev/null | head -"$height" > "$preview_file"
                    preview "$preview_file" "$list_top" "$height" "$preview_x" 0
                fi
                last_cur=$cur
            fi
        fi

        row=$((list_top + height))
        _draw_spacer

        # Define a "Soft Bold" that only changes the foreground, not the background
        local SB="\e[1;37m" 
        # Define a "Soft Reset" that returns to Hint color while keeping BG_MAIN
        local SR="\e[22m${FG_HINT_ESC}"

        _draw_controls " ${SB}~${SR} Home | ${SB}x/c/v${SR} Cut/Copy/Paste | ${SB}r${SR} Rename | ${SB}?${SR} Help | ${SB}q${SR} Quit"

        _draw_footer

        # 6. INPUT HANDLING
        IFS= read -rsn1 key < /dev/tty || break

        # --- A. Escape Sequence Handler (Arrows / ESC) ---
        if [[ "$key" == $'\e' ]]; then
            stty -icanon -echo min 0 time 0
            local next_chars=$(dd bs=3 count=1 2>/dev/null)
            stty icanon echo
            
            if [[ -z "$next_chars" ]]; then
                # --- THIS IS THE ESCAPE KEY LOGIC ---
                if [[ "$ui_mode" == "SEARCH" ]]; then
                    # 1. Capture the path of the currently focused item before clearing
                    local last_p="${raw_list[$cur]%%|*}"
                    
                    # 2. Reset Search State
                    search_query=""
                    prompt_pos=0
                    ui_mode="NAV"

                    # 3. Restore the full Master List
                    raw_list=("${master_raw_list[@]}")
                    count=${#raw_list[@]}

                    # 4. RESTORE FOCUS: Find where 'last_p' is in the full list
                    for ((idx=0; idx<count; idx++)); do
                        if [[ "${raw_list[$idx]%%|*}" == "$last_p" ]]; then
                            cur=$idx
                            break
                        fi
                    done
                    
                    # 5. Trigger full UI refresh to show all files again
                    rebuild=1
                    _init_tui
                elif [[ "$ui_mode" != "NAV" ]]; then
                    # Handle other modes (CMD, RENAME, etc)
                    ui_mode="NAV"; prompt_buffer=""; prompt_pos=0; rebuild=1
                else 
                    return 1 # Exit file_manager if already in NAV mode
                fi
            else
                case "$next_chars" in
                    "[D") # Left Arrow
                        preview_offset=0
                        if [[ "$ui_mode" != "NAV" ]]; then
                            (( prompt_pos > 0 )) && ((prompt_pos--))
                        else
                            # NAV MODE: Back to parent
                            last_path="$root_dir"; root_dir=$(cd "$root_dir/.." && pwd); rebuild=1; cur=-2
                        fi ;;
                    "[C") # Right Arrow
                        preview_offset=0
                        if [[ "$ui_mode" != "NAV" ]]; then
                            local buf="$prompt_buffer"; [[ "$ui_mode" == "SEARCH" ]] && buf="$search_query"
                            (( prompt_pos < ${#buf} )) && ((prompt_pos++))
                        else
                            # NAV MODE: Logic formerly in _handle_selection
                            local node="${raw_list[$cur]}"
                            local p="${node%%|*}"
                            if [[ "${node##*|}" == "true" ]]; then
                                root_dir=$(cd "$p" && pwd); cur=0; rebuild=1; _init_tui
                            else
                                TUI_RESULT="$p"; return 0
                            fi
                        fi ;;
                    "[A"|"[B") # Up/Down
                        preview_offset=0
                        if [[ "$ui_mode" == "CMD" || "$ui_mode" == "SUDO_CMD" ]]; then
                            if [[ "$next_chars" == "[A" ]]; then # UP (Older)
                                if (( hist_ptr < ${#cmd_history[@]} - 1 )); then
                                    ((hist_ptr++))
                                    prompt_buffer="${cmd_history[$hist_ptr]}"
                                    prompt_pos=${#prompt_buffer}
                                fi
                            else # DOWN (Newer)
                                if (( hist_ptr > 0 )); then
                                    ((hist_ptr--))
                                    prompt_buffer="${cmd_history[$hist_ptr]}"
                                    prompt_pos=${#prompt_buffer}
                                elif (( hist_ptr == 0 )); then
                                    hist_ptr=-1
                                    prompt_buffer=""
                                    prompt_pos=0
                                fi
                            fi
                            # Use your surgical redraw to show the recalled command
                            _refresh_prompt
                            continue
                        fi

                        # NAV MODE: Standard Up/Down (Keep existing code below)
                        if [[ "$ui_mode" == "NAV" ]]; then
                            [[ "$next_chars" == "[A" ]] && { [[ $cur -gt 0 ]] && ((cur--)); }
                            [[ "$next_chars" == "[B" ]] && { [[ $cur -lt $((count-1)) ]] && ((cur++)); }
                        fi ;;
                esac
            fi
            continue
        fi

        # --- B. PROMPT MODE (Search/Cmd/Sudo/Rename/New) ---
        if [[ "$ui_mode" != "NAV" ]]; then
            case "$key" in
                "") # ENTER in SEARCH mode
                    if [[ "$ui_mode" == "SEARCH" ]]; then
                        # --- THE SURGICAL FIX: Check if query is empty ---
                        # We strip the leading space if it exists
                        local check_q="${search_query# }"
                        
                        if [[ -z "$check_q" ]]; then
                            # EMPTY PROMPT: Behave exactly like ESCAPE
                            local last_p="${raw_list[$cur]%%|*}"
                            search_query=""
                            prompt_pos=0
                            ui_mode="NAV"
                            raw_list=("${master_raw_list[@]}")
                            count=${#raw_list[@]}
                            
                            # Restore focus to previously viewed item
                            for ((idx=0; idx<count; idx++)); do
                                [[ "${raw_list[$idx]%%|*}" == "$last_p" ]] && cur=$idx && break
                            done
                            
                            rebuild=1
                            _init_tui
                            continue
                        else
                            # NON-EMPTY: Standard confirm filter logic
                            ui_mode="NAV"
                            _update_display_path
                            local p_row=$(( PADDING_TOP + 3 ))

                            # adjustments needed to prompt placement in fullscreen mode
                            [[ -n "$BACKTITLE" && "$TUI_MODE" == 'fullscreen' ]] && p_row=$(( PADDING_TOP + 4 ))
                            
                            printf "\e[${p_row};$((PADDING_LEFT + 2))H${BG_MAIN_ESC}%-*s${RESET}${BG_MAIN_ESC}" \
                                   "$((MAX_WIDTH - 4))" "$header_msg" >&2
                            rebuild=0
                            continue
                        fi
                    
                    elif [[ -z "$prompt_buffer" ]]; then
                        # Empty prompt: return to NAV
                        ui_mode="NAV"; prompt_pos=0; rebuild=1
                    
                    elif [[ "$ui_mode" == "CMD" || "$ui_mode" == "SUDO_CMD" ]]; then
                        # --- SAVE TO HISTORY ---
                        if [[ -n "$prompt_buffer" ]]; then
                            # Add to start of history (most recent first)
                            cmd_history=("$prompt_buffer" "${cmd_history[@]}")
                            # Limit history size to 50 items to save memory
                            [[ ${#cmd_history[@]} -gt 50 ]] && unset 'cmd_history[50]'
                        fi
                        _execute_mode_action
                        prompt_buffer=""; prompt_pos=0; hist_ptr=-1 # Reset pointer
                        _init_tui
                        continue 
                    
                    elif [[ "$ui_mode" == "NEW_F" || "$ui_mode" == "NEW_D" || "$ui_mode" == "RENAME" ]]; then
                        # 1. RUN ACTION (mv, touch, or mkdir)
                        _execute_mode_action
                        
                        # 2. RESET STATE (Don't exit the script!)
                        ui_mode="NAV"
                        prompt_buffer=""
                        prompt_pos=0
                        
                        # 3. REBUILD LIST
                        # This ensures the new file/folder shows up in the sidebar
                        rebuild=1
                        _init_tui
                        
                        # 4. SKIP NAV LOGIC
                        continue
                    fi
                    ;;
                $'\t') # TAB
                    if [[ "$ui_mode" == "SEARCH" ]]; then
                        # 1. Existing Search Logic: Always exit to NAV
                        ui_mode="NAV"; prompt_pos=0; rebuild=1
                        continue
                    elif [[ "$ui_mode" == "CMD" || "$ui_mode" == "SUDO_CMD" ]]; then
                        if [[ -n "$prompt_buffer" ]]; then
                            # 2. NEW FEATURE: Completion (Only if there is text)
                            _get_tab_completion
                            _refresh_prompt
                            continue
                        else
                            # 3. Existing CMD Logic: Exit if empty
                            ui_mode="NAV"; prompt_pos=0; rebuild=1
                            continue
                        fi
                    elif [[ -z "$prompt_buffer" ]]; then
                        # 4. Fallback for other modes (RENAME, etc)
                        ui_mode="NAV"; prompt_pos=0; rebuild=1
                    fi
                    ;;

                $'\e') # Arrows
                    case "$next_chars" in
                        "[D") (( prompt_pos > 0 )) && ((prompt_pos--)) ;;
                        "[C") 
                            local limit=$([[ "$ui_mode" == "SEARCH" ]] && echo ${#search_query} || echo ${#prompt_buffer})
                            (( prompt_pos < limit )) && ((prompt_pos++)) 
                            ;;
                    esac ;;

                $'\177'|$'\b') # Backspace
                    if (( prompt_pos > 0 )); then
                        if [[ "$ui_mode" == "SEARCH" ]]; then
                            # 1. Update query
                            search_query="${search_query:0:prompt_pos-1}${search_query:prompt_pos}"
                            ((prompt_pos--))

                            # 2. FAST SURGICAL UPDATES
                            _get_prompt_msg
                            _refresh_prompt
                            _refresh_sidebar_only
                            continue # Skip slow rebuild
                        else
                            prompt_buffer="${prompt_buffer:0:prompt_pos-1}${prompt_buffer:prompt_pos}"
                            ((prompt_pos--))
                            _refresh_prompt
                            continue
                        fi
                    fi ;;

                *) # Character Input
                    if [[ "$key" == [[:print:]] ]]; then
                        if [[ "$ui_mode" == "SEARCH" ]]; then
                            # 1. Update query
                            search_query="${search_query:0:prompt_pos}${key}${search_query:prompt_pos}"
                            ((prompt_pos++))

                            # 2. SURGICAL UPDATES (Do not use rebuild=1)
                            _get_prompt_msg       # Update the header string
                            _refresh_prompt       # Draw the black bar immediately
                            _refresh_sidebar_only # Filter and draw the list immediately
                            
                            continue # Skip Nav logic
                        else
                            prompt_buffer="${prompt_buffer:0:prompt_pos}${key}${prompt_buffer:prompt_pos}"
                            ((prompt_pos++))
                            _refresh_prompt
                            continue
                        fi
                    fi
                    completion_idx=-1 # Reset completion cycle when user types
                    ;;

            esac

            # --- SURGICAL REDRAW ---
            if [[ "$ui_mode" != "NAV" ]]; then
                _refresh_prompt
                
                if [[ "$ui_mode" == "SEARCH" ]]; then
                    # We only want to rebuild the list if the user hasn't typed 
                    # in the last few milliseconds, OR we do a shallow filter
                    # To keep it 100% lag-free, let's just refresh the prompt 
                    # and only filter the sidebar every 2nd or 3rd keystroke, 
                    # or simply accept a slightly slower filter for a faster cursor.
                    
                    # For Bash 3.2, the best balance is:
                    _refresh_sidebar_only # A function that only draws the filenames
                fi
                
                [[ "$ui_mode" != "SEARCH" ]] && continue
            fi
        fi

        # --- C. NAV MODE HOTKEYS ---
        case "$key" in
            "q") return 1 ;; # Now "q" will exit correctly
            "") # ENTER key
                if [[ "$ui_mode" != "NAV" ]]; then
                    # We are in a prompt (SEARCH, CMD, etc.)
                    _execute_mode_action
                    continue
                else
                    # We are in NAVIGATION mode - Restore selection/CD logic
                    local node="${raw_list[$cur]}"
                    local p="${node%%|*}"
                    local label="${node#*|}"
                    label="${label%|*}"

                    if [[ "$label" == ".." || "${node##*|}" == "true" ]]; then
                        # Standard directory navigation
                        root_dir=$(cd "$p" && pwd)
                        [[ "$label" == ".." ]] && last_path="${raw_list[$cur]%%|*}" || last_path=""
                        rebuild=1; cur=-2; _init_tui
                    else
                        # File selection
                        TUI_RESULT="$p"
                        return 0
                    fi
                fi
                ;;
            $'\t') # TAB: Toggle Tag by Path
                local path="${raw_list[$cur]%%|*}"
                local label="${raw_list[$cur]#*|}"
                label="${label%|*}"
                
                if [[ "$label" != ".." ]]; then
                    local found=-1
                    for i in "${!selected_paths[@]}"; do
                        [[ "${selected_paths[$i]}" == "$path" ]] && found=$i && break
                    done

                    if [[ $found -ge 0 ]]; then
                        unset 'selected_paths[$found]'
                        selected_paths=("${selected_paths[@]}")
                    else
                        selected_paths+=("$path")
                    fi
                fi
                [[ $cur -lt $((count - 1)) ]] && ((cur++))
                # No rebuild=1 needed here if you only update the two rows, 
                # but for simplicity, rebuild=0 and a surgical redraw is better.
                ;;

            "e") # Instant Edit
                local p="${raw_list[$cur]%%|*}"
                [[ "${raw_list[$cur]##*|}" == "false" ]] && {
                    _show_cursor; stty sane; printf "\e[0m\e[H\e[J" >&2
                    ${EDITOR:-vi} "$p"
                    stty -echo; _init_tui; _hide_cursor; rebuild=1
                } ;;

            ",") # Toggle Detailed List View (comma)
                show_details=$(( 1 - show_details ))
                show_help=0; rebuild=1; _init_tui ;;

            "?") # Toggle Help
                show_help=$(( 1 - show_help ))
                last_cur=-1; rebuild=0 ;;

            "~") root_dir="$HOME"; rebuild=1; cur=0 ;;

            "!") ui_mode="SUDO_CMD"; prompt_buffer=""; prompt_pos=0; rebuild=0; show_help=0
                 _refresh_prompt; continue ;;
                 
            ":")
                 ui_mode="CMD"; prompt_buffer=""; prompt_pos=0; rebuild=0; show_help=0
                 _refresh_prompt; continue ;;

            "/") ui_mode="SEARCH"; search_query=""; prompt_pos=0; rebuild=0; show_help=0
                 _refresh_prompt; continue ;;

            "f") ui_mode="NEW_F"; search_query=""; prompt_pos=0; rebuild=0; show_help=0
                 _refresh_prompt; continue ;;

            "d") ui_mode="NEW_D"; search_query=""; prompt_pos=0; rebuild=0; show_help=0
                 _refresh_prompt; continue ;;
            
            "r") # Rename
                 ui_mode="RENAME"
                 local n="${raw_list[$cur]#*|}"
                 prompt_buffer="${n%|*}"
                 prompt_pos=${#prompt_buffer}
                 
                 # NEW: Don't wait for the loop to redraw
                 rebuild=0
                 show_help=0
                 _refresh_prompt
                 continue ;;

            "x"|"c") # Toggle Cut/Copy
                local op=$([[ "$key" == "x" ]] && echo "CUT" || echo "COPY")
                
                _toggle_clipboard() {
                    local p=$1 act=$2 found=-1
                    for i in "${!clipboard_list[@]}"; do
                        [[ "${clipboard_list[$i]}" == "$p" ]] && found=$i && break
                    done
                    if [[ $found -ge 0 ]]; then
                        unset 'clipboard_list[$found]'
                        clipboard_list=("${clipboard_list[@]}")
                    else
                        clipboard_list+=("$p")
                        clipboard_op="$act"
                    fi
                }

                # Process tags or focus
                if [[ ${#selected_paths[@]} -gt 0 ]]; then
                    for p in "${selected_paths[@]}"; do _toggle_clipboard "$p" "$op"; done
                    selected_paths=() # Clear tags after action
                else
                    _toggle_clipboard "${raw_list[$cur]%%|*}" "$op"
                    [[ $cur -lt $((count - 1)) ]] && ((cur++))
                fi
                ;;

            "v") # Paste
                [[ ${#clipboard_list[@]} -eq 0 ]] && continue
                for item in "${clipboard_list[@]}"; do
                    [[ ! -e "$item" ]] && continue
                    local name="${item##*/}"; local target="$root_dir/$name"
                    if [[ -e "$target" ]]; then
                        local base="${name%.*}"; local ext="${name##*.}"
                        [[ "$base" == "$ext" ]] && ext="" || ext=".$ext"
                        local i=1
                        while [[ -e "$root_dir/${base}_$i$ext" ]]; do ((i++)); done
                        target="$root_dir/${base}_$i$ext"
                    fi
                    [[ "$clipboard_op" == "CUT" ]] && mv -f "$item" "$target" || cp -rf "$item" "$target"
                done
                [[ "$clipboard_op" == "CUT" ]] && clipboard_list=()
                rebuild=1; _init_tui ;;

            "h") # Move Left (Back to parent)
                last_path="$root_dir"
                root_dir=$(cd "$root_dir/.." && pwd)
                rebuild=1; cur=-2 ;;

            "j") # Move Down
                [[ $cur -lt $((count - 1)) ]] && ((cur++))
                rebuild=0; continue ;;

            "k") # Move Up
                [[ $cur -gt 0 ]] && ((cur--))
                rebuild=0; continue ;;

            "l") # Move Right (Enter directory or select file)
                local node="${raw_list[$cur]}"
                local p="${node%%|*}"
                if [[ "${node##*|}" == "true" ]]; then
                    # Navigate into directory
                    root_dir=$(cd "$p" && pwd)
                    cur=0; rebuild=1; _init_tui
                else
                    # Select file
                    TUI_RESULT="$p"; return 0
                fi ;;

            "g"|"s") # HOME: Jump to top
                cur=0; rebuild=0; continue ;;

            "G"|"e") # END: Jump to bottom
                cur=$((count - 1)); rebuild=0; continue ;;

            "J") # PAGE DOWN: Move down by half the height
                cur=$((cur + height / 2))
                [[ $cur -ge $count ]] && cur=$((count - 1))
                rebuild=0; continue ;;

            "K") # PAGE UP: Move up by half the height
                cur=$((cur - height / 2))
                [[ $cur -lt 0 ]] && cur=0
                rebuild=0; continue ;;

            "i") # Toggle Ignored Files
                show_ignored=$(( 1 - show_ignored ))
                # Force a data refresh
                last_dir="FORCE_REFRESH" 
                rebuild=1
                # No need for _init_tui here, the loop will catch rebuild=1
                ;;

            "[") # Page Up (file preview)
                (( preview_offset -= height ))
                [[ $preview_offset -lt 0 ]] && preview_offset=0
                last_cur=-3 # Force redraw Step 5
                rebuild=0; continue ;;

            "]") # Page Down (file preview)
                (( preview_offset += height ))
                last_cur=-3 # Force redraw Step 5
                rebuild=0; continue ;;

            '.') # Toggle Hidden
                show_hidden=$(( 1 - show_hidden ))
                show_help=0
                last_path="${raw_list[$cur]%%|*}"; cur=-2; rebuild=1 ;;
        esac
    done
}
