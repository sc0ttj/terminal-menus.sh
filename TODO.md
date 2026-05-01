# terminal-menus.sh: TODO
------------------------------------------------------------------

## Make sure $TUI_RESULT is always sent to stdout and the contains correct data

* $TUI_RESULT should always hold the return data of the widget after the widget has ended
* Use `echo -e` to send to stdout
* Use with the correct, appropriate return codes (0 is ok, 1 is error, etc)

## Rename `file_navigator` to `filepicker`
Make it more consistent with other widgets.

## Rename `file_manager` to `filemanager`
Make it more consistent with other widgets.

### Fix `file_navigator` multiple selection

* Both widgets should use this fixed function called `_handle_selection`.
* Currently there's a worse one inside `file_navigator`, which forgets selection lists when you `cd` to another dir.

```sh
_handle_selection() {
    local results=""
    local tagged_count=0

    # 1. Collect everything tagged with TAB
    # In file_manager, selected_paths usually stores the string path, not just a 1/0
    for path in "${selected_paths[@]}"; do
        if [[ "$path" != "0" && -n "$path" ]]; then
            results+="$path"$'\n'
            ((tagged_count++))
        fi
    done
    
    # 2. If multi-select exists, return it
    if [[ $tagged_count -gt 0 ]]; then 
        TUI_RESULT="${results% }" # Trim trailing space
        return 2 # Signal to exit the widget
    fi

    # 3. Fallback to item under cursor
    local node="${raw_list[$cur]}"
    local p="${node%%|*}"
    local label="${node#*|}"; label="${label%|*}"
    local is_d="${node##*|}"

    if [[ "$label" == ".." || "$is_d" == "true" ]]; then
        # Navigate into Directory
        root_dir=$(cd "$p" && pwd)
        # last_path logic for the '..' highlight
        [[ "$label" == ".." ]] && last_path="${p%/*}" || last_path=""
        rebuild=1; cur=-2; _init_tui
        return 0 # Stay in widget
    else
        # Select single File
        TUI_RESULT="$p"
        return 2 # Signal to exit the widget
    fi
}

```


Quote:
```
Storage: When a user hits TAB, store the absolute path 
(e.g., $(pwd)/$filename) in the `selected_paths` array.

Joining: Use `results+="$path"$'\n'` to build the string.

Return: Always echo -e "$TUI_RESULT" or printf "%b" "$TUI_RESULT" 
at the end so the subshell RES=$(...) captures the vertical list 
correctly.
```


For file_navigator:
```
        "") # ENTER
          _handle_selection
          [[ $? -eq 2 ]] && return 0
          ;;
            
        "l") # Vim Right
          _handle_selection
          [[ $? -eq 2 ]] && return 0
          ;;
```

## Improve `file_manager`

### More readable key handling code

```
# Define these at the top of your library
KEY_UP=$'\e[A'
KEY_DOWN=$'\e[B'
KEY_ESC=$'\e'
KEY_ENTER=""

...

# Then in your file_manager
case "$key" in
    "$KEY_UP")   ((cur--)) ;;
    "$KEY_DOWN") ((cur++)) ;;
    "$KEY_ESC")  [[ "$ui_mode" == "NAV" ]] && return ;;
esac
```

### Fix fullscreen
In fullscreen mode:
* the help info should be indented one space more (keep same width, just move it to the right one space).

### Use an external preview script

Easier to upgrade if its external.

------------------------------------------------------------------

## Improve `mainmenu`

Add an option to maintain the filter (and keep the filter input text), even when changing menu items.

Sort by column:
- Press 1 to sort by column 1, asc. Press again to sort by column 1 desc.
- Press 2 to sort by column 2, asc. Press again to sort by column 2 desc.
- etc.

------------------------------------------------------------------

## Fix: remove calls to `tput`

Use raw ANSI/escape char calls instead. Makes it faster.

------------------------------------------------------------------

## Re-instate dropdown menus

Dropdown menus (space to toggle expand/collapse, up/down to navigate, space to select) have gone missing from a previous version.

## Two column forms

- in fullscreen mode:
  - if form is taller than the visible window, split the form into two columns
- in all other modes: 
  - if form is taller than the UI box, split the form into two columns

## Scrollable `form` fields

Make sure "dropdowns" & "filter dropdowns" have:
- a max height of 6
- a scrollable viewport if items exceed 6


------------------------------------------------------------------

## Improve demos

### `form`

Add all field types (headings, input, password input, checklist, radiolist, dropdown, separators).

------------------------------------------------------------------



## New widget: `controlpanel`

Usage:

```sh

FORM_1=("Settings" "Adjust ALSA settings" \
  "> Some Input=100" \
  "[ ] foo" \
  "[x] bar" \
  "Some Type:" \
  "(*) foo" \
  "( ) bar" \
  "<Save> echo 'saved ALSA settings'" \
)

FORM_2=("Settings" "Adjust Bluetooth settings" \
  "> Some thing=foobarbaz" \
  "[x] foo" \
  "Some Type:" \
  "( ) foo" \
  "(*) bar" \
  "<Save> echo 'saved bluetooth settings'" \
)

# ...etc

PANEL_DATA=(
  "0|audio|Audio|true"
  "1|alsa|ALSA|false:FORM_1"
  "1|bluetooth|Bluetooth|false:FORM_2"
  "1|pulse|Pulse|false:FORM_3"
)

TUI_MODE="fullscreen"
controlpanel "System settings" "Select a category" "$PANEL_DATA" > final_config.txt
```

A tree menu, in the "left pane", 30% screen width.
A 1 or 2 column form, in the "right pane", 70% screen width.

Pressing up/down/j/k on the menu moves up and down.
Pressing left and right on the menu expands/collapses items.

