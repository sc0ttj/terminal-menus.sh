# terminal-menus.sh: TODO
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

## Scrollable `form` fields

Make sure "dropdowns" have:
- a max height of 6
- scrollable items area, if items exceed 6


------------------------------------------------------------------

## New widget: `textarea`

A simple, writable, multi-line textarea that has key bindings and UX features which mimics more moden editors, for easier multi-line editing in a terminal (better than readline etc).

* up/down arrows move up/down 1 line
* left/right arrows move 1 char left/right
* Ctrl-a highlight all text
* HOME key moves to start of current line
* END key moves to start of current line
* Shift+enter carriage return (move to new line)
* has concept of "separators" (such as `"-","_"," ","+","." and ","`) so it can split words, lines, etc:
  * shift+right highlights next letter
  * shift+left highlights prev letter
  * shift+up highlights backwards, from the char on line above (or end of line), to previous position 
  * shift+down highlights forwards, from previous position up to the char under previous position (or end of line) on next line. 
  * shift+right highlights next letter
  * ctrl+left move to start of current word (press again to move to start of previous word) 
  * ctrl+right move to end of current word (press again to move to end of next word)
  * ctrl+shift+left highlight and move to start of current word (press again to highlight and move to start of previous word) 
  * ctrl+shit+right highlight and move to end of current word (press again to highglight and move to end of next word)
  * delete key and backspace key should delete all highlighted text
  * cut, copy, paste should work (ctrl+x, ctrl+c, ctrl+v)
  * ctrl+s save latest contents back to file
  * ctrl+q key must be used quit the widget.

The path and filename would be in the BACKTITLE, no need to put them in the widget UI.

The overall goal would be a text-editor like widget, that returns the final file contents to stdout and saves it in $TUI_RESULT too. If any unsaved changes, it should ask to save latest contents back to the file on exit, using a modal popup yesno dialog.

------------------------------------------------------------------

## New widget: `chat`

A chat interface, you supply "the backend" - your own send/receive functions, and "/foo" style commands.

The chat interface should contain:
* main chat window, with a user list on the right (or left if POSITION_USERS=left)
* input text field at bottom, with send button to the right (or at top, if POSITION_INPUT=top)

The widget should:
* document and provide variables, tmp files and data structures that can be passed into the users send/receive functions/scripts and "/foo" style commands as params ($1, $2, etc). 

The chat widget should be generic enough and simple enough to serve as a generic UI frontend for email, IRC, HTTP(S) messaging, local network messaging, easy to hook up to various different "backends".

In any case, the "backend" would just be shell script functions or scripts.

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
Pressing ENTER loads the relevant form in the "right pane" and focuses on its first item.

---------------------------------------------------------------------

