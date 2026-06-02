# terminal-menus.sh: TODO
------------------------------------------------------------------

### Fix `file_navigator` multiple selection

* Both widgets should use this fixed function called `_handle_selection`.
* Currently there's a worse one inside `file_navigator`, which forgets selection lists when you `cd` to another dir.

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

------------------------------------------------------------------

## Make sure $TUI_RESULT is always sent to stdout and the contains correct data

* $TUI_RESULT should always hold the return data of the widget after the widget has ended
* Use `echo -e` to send to stdout
* Use with the correct, appropriate return codes (0 is ok, 1 is error, etc)


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

