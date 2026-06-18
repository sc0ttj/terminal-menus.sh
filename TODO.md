# terminal-menus.sh: TODO
------------------------------------------------------------------

## Allow Nerd font icons

I want a way to support using Nerd font icons in input data, using placeholders like so:

```
str="{icon_name} Foo bar"
```

Example

```
str="{folder} My Documents"
```

Is it possible to support "Nerd fonts" in this way, without knowing which "Nerd font" is being used? 

The end goal would be for users to be able to easily, optionally, use nerd font icons, in their menus, tables, lists, input text, etc.

------------------------------------------------------------------

## Fix `filemanager` and `filepicker`

* Persist TAB selection when switching between normal and list view (by pressing the "," key) 
* Persist TAB selection when changing directories:
  - all currently selected files and dirs (current selection) should remain selected after changing dir
  - selecting more items should append them to the current selection 
  - this should include executable and hidden files and other files rendered with custom styles

## Fix `filemanager` "list view"

* Press "," to enter "list view"
* The contents columns are not nicely aligned

EXAMPLE 1:

                                              === Advanced file manager ===
                                              Path: ~/sites/github/sc0ttj/terminal-menus.sh

                                               ..
                                               screenshots/                   drwxr-xr-x  0 0 4.0K Jun 18 21:16
                                               scripts/                       drwxr-xr-x  0 0 4.0K Jun 18 21:16
                                               test/                          drwxr-xr-x  0 0 4.0K Jun 18 21:55
                                               LICENSE.md                     -rw-r--r--  0 0 1.1K Jun 18 21:15
                                               README.md                      -rw-r--r--  0 0 27K Jun 18 21:55
                                               TODO.md                        -rw-r--r--  0 0 2.9K Jun 18 22:20
                                               preview.sh                     -rw-r--r--  0 0 1.2K Jun 18 21:16
                                               terminal-menus-demo.sh         -rwxr-xr-x  0 0 21K Jun 18 21:16
                                               terminal-menus.sh              -rw-r--r--  0 0 223K Jun 18 22:29


EXAMPLE 2:

                                              === Advanced file manager ===
                                              Path: ~

                                               ..
                                               Choices/                       drwxr-xr-x  0 0 4.0K Dec 7  2021
                                               Desktop/                       drwxr-xr-x  65534 65534 4.0K Dec 11  2
                                               Documents/                     drwxr-xr-x  65534 65534 4.0K Jul 11  2
                                               Downloads/                     drwxr-xr-x  65534 65534 4.0K Nov 12  2
                                               Music/                         drwxr-xr-x  65534 65534 4.0K Sep 2  20
                                               Startup/                       drwxr-xr-x  0 0 4.0K Oct 15  2020
                                               Sync/                          drwxr-xr-x  0 0 4.0K Feb 12  2023
                                               bin/                           drwxr-xr-x  65534 65534 12K May 13 21:
                                               files/
                                               ftpd/                          drwxrwxrwx  1000 0 3 Jan 7  2008
                                               images/                        drwxr-xr-x  0 0 4.0K Sep 2  2024
                                               livesprojects/                 drwxr-xr-x  0 0 4.0K Dec 2  2024
                                               makehuman/                     drwxr-xr-x  0 0 4.0K Sep 16  2023
                                               my-documents/                  drwxr-xr-x  0 0 4.0K Apr 27  2021

I want the columns to be nicely aligned without being too wide for the TUI_LAYOUT chosen.


## Fix `kanban` widget

* Fix the kanban widget:
- I can't see any tickets in the board (but I can see them in list view after pressing "/")


## Support page up and page down keys

* In widgets with scrollable lists, add support for page up/page down keys
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

