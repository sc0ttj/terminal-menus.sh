# terminal-menus.sh: TODO
------------------------------------------------------------------


Improve `filtertable`:
* pressing BACKSPACE in empty filter input should focus on first item in list
* pressing TAB in an empty filter should behave the same as pressing ENTER in an empty filter - focus on first item in list
* make its controls more consistent with other filter inputs (filtertable, configtree, tree)

Fix `filemanager`
* If focused item in sidemenu is a dir, list its contents in the preview window (ls -1, with dirs first, and dirs suffixed with "/")
* Also fix the preview.sh script if needed

Fix filter inputs:
* some filter inputs, in some widgets, do not allow typing "j" or "k" into the input, but they should

Improve `textbox`:
* Add page up/page down controls

Improve `filtermenu`:
* when in menu (not in filter input), pressing "/" should move focus to filter input 
* when in menu (not in filter input), pressing "BACKSPACE" should move focus to filter input 
* when in filter input, pressing DOWN key should focus on first item in menu (like ENTER does)

Improve `tree` and `configtree`:
* Add: press TAB key to switch between filter input and viewport content
* Add ENV var option to return values (`/usr/local/share/doc/manual.txt` instead of keys (`usr/local/share/doc/man`)

Fix `filemanager`:
* make it support the `TUI_CD_FILE` env var, just like `filepicker` does.
* add an example to README.md of how to use it for a "cd to dir on exit" feature (where the terminal cds to the dir the filepicker or filemanager was in on exit)

Improve `filemanager`:
* the command prompt history should be saved to a file in /tmp for persistence each desktop session

Fix `filepicker` and `filemanager`
* If focused item in sidemenu is a dir, list its contents in the preview window (ls -1, with dirs first, and dirs suffixed with "/")

Fix `filepicker`:
* add "[" and "]" key bindings for page up and page down (to match `filemanager`)

Improve `spreadsheet` controls:
* in the controls text, replace "z/Z Undo/Redo" with "? Help"
* then add a popup help menu, triggered by "?" and similar to the `kanban` widget, listing all controls and supported Expressions (listed in README.md)

Fix `spreadsheet` demo:
* ~~typing "=" into the EDIT input of the spreadsheet causes an error `ash: =: unknown operand`~~
* ~~typing "(" into the EDIT input of the spreadsheet causes an error `ash: closing paren`~~
  Fixed: replaced `[[ -z "$key" || "$key" == $'\r' || "$key" == $'\n' ]]` with
  POSIX-safe `[ -z "$key" ] || [ "$key" = "$cr" ] || [ "$key" = "$lf" ]` where
  `cr`/`lf` are pre-computed via `$(printf '\r')` / `$(printf '\n')`. Also added
  "unknown operand" and "closing paren" to `assert_no_shell_errors` checks.


------------------------------------------------------------------

## New Feature: custom keybindings

For some widgets, custom key bindings that popup modal widgets will be very useful, particularly for command palette style popups.

The user should be able to set `TUI_EXTRA_KEYS` env var like so:

```
TUI_EXTRA_KEYS="
a=modal \"menu '' '' 1 'foo bar' 'second' 'third'\"
b=modal \"checklist '' '' 1 'foo bar' 'second' 'third'\"
B=modal \"checklist '' '' 1 'other' 'more' 'third'\"
ctrl_f=modal "inputbox '' '' '' \"
shift_f=modal "infobox '' '' 'foo'\"
"
filemanager ...
```

The widgets should run the commands when the user presses the defined key binding (before the = sign).


------------------------------------------------------------------

## Fix: remove calls to `tput`

Use raw ANSI/escape char calls instead. Makes it faster.

------------------------------------------------------------------

## Two column forms

* in fullscreen mode:
  - if form is taller than the visible window, split the form into two columns
* in all other modes: 
  - if form is taller than the UI box, split the form into two columns

## Scrollable `form` fields

Make sure "dropdowns" have:
- a max height of 6
- scrollable items area, if items exceed 6


------------------------------------------------------------------

## New widget: `chat`

A chat interface, you supply your own send/receive functions, and "/foo" style commands.

The chat interface should contain:
* main chat window, with a user list on the right
* input text field at bottom, with send button to the right

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

---------------------------------------------------------------------

