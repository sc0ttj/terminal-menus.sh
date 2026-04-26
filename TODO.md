# terminal-menus.sh: TODO
------------------------------------------------------------------

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

### Special `cd` handling in the CMD and SUDO_CMD prompts
If you run `cd foo/bar` in a command prompt, the file_manager should `cd` to that dir, not only the shell.

### Fix fullscreen
In fullscreen mode:
* the help info should be indented one space more (keep same width, just move it to the right one space).

### Use an external preview script

Easier to upgrade if its external.

### Fix command prompts working dir
Fix: when a command prompt opens, it should set the prompts working dir to the current dir the file manager is in.
* I am in `~`, and I open file_manager
* In file_manager, I use arrows to cd to `~/foo/`
* I hit "$" and type "touch bar" and hit ENTER
* The file `~/foo/bar` should be created, not `~/bar`

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

