# terminal-menus.sh: TODO
------------------------------------------------------------------

## Fix `kanban`

### Allow choosing the default selected item on startup
* Pass in column number ($2) and item number ($3) at the end, like mainmenu.
* Example: `kanban "Project" "" ~/my_project 2 4` selects the 4th item in column 2
* If the item doesn't exist, or options not given, default to 1 1

### Handle completion dates better
* Completion dates should be empty when creating a note
* Completion date should be added to the note (yyyy-mm-dd-hh:mm:ss) when moved into the final column in the kanban
* Completion date should be removed from the note when the note is moved out of the final column of the kanban


### Add due date
* Due date should be empty when creating a note
* Items should be sortable by due date ("o" key)
* Due date should be a visibile column in the filtertable 

------------------------------------------------------------------

## Allow Nerd font icons

I want a way to support using Nerd font icons in input data, using placeholders like so:

```
str="{icon_name} Foo bar"
```

Example

```
item1="{folder} My Documents"
```

Is it possible to support "Nerd fonts" in this way, without knowing which "Nerd font" is being used? 

The end goal would be for users to be able to easily, optionally, use nerd font icons, in their menus, tables, lists, input text, etc.

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

