# terminal-menus.sh: TODO
------------------------------------------------------------------

## Fix typing into dropdown in `form` widget

Typing into the dropown to filter it nearly works perfect, but it leaves rendering artifacts after choosing an item.

For example, I focused on the dropdown, I hit SPACE to open it, I type "us" and I focused on "USA" and hit SPACE to choose it.

Then I see this (there is a "USA" artifact above "Deployment:"):

                                            terminal-menus.sh demo 16 of 23 - form

                                              User:
                                               > root

                                              Password:
                                               > ****                       🔑

                                              Country:
                                              USA ▾

                                              Enabled connections:
                                              [ ] Ethernet
                                              [x] Wifi
                                              [ ] Fibre
                                               USA
                                              Deployment:
                                              (*) Production
                                              ( ) Staging


                                              TAB/Arrows Nav | Space Toggle | Enter Submit



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

## Fix `filemanager` and `filepicker`

* Persist TAB selection when switching between normal and list view (by pressing the "," key) 
* Persist TAB selection when changing directories:
  - all currently selected files and dirs (current selection) should remain selected after changing dir
  - TAB selecting more items in the new dir should append them to the current selection 
  - this should include executable and hidden files and other files rendered with custom styles

------------------------------------------------------------------

## Support page up and page down keys in various widgets

* In widgets with scrollable lists (menus/tables), add support for page up/page down keys
* For the `filemanager` and `filepicker` widgets:
  - the key bindings for page up/page down keys should move the sidebar focus up/down (like J/K)

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

