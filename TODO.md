# terminal-menus.sh: TODO
------------------------------------------------------------------

## Fix: remove calls to `tput`

Use raw ANSI/escape char calls instead. Makes it faster.

------------------------------------------------------------------

## Re-instate dropdown menus in the `form` widget

Dropdown menus (space to toggle expand/collapse, up/down to navigate, space to select) have gone missing from a previous version.

Re-implement dropdown menus in the `form` widget so that the following syntax works:

```sh
FORM_OUT=$(form "Demo form" "Enter your details:" \
    "> User:user=$(whoami)" \
    ">* Password:password" \
    "Country:" \
    "{ } United Kingdom:uk,=USA:usa,South Africa:southafrica" \
    "Enabled connections:" \
    "[ ] Ethernet:eth0" \
    "[x] Wifi:wlan0" \
    "[ ] Fibre:eth1" \
    "Deployment:" \
    "(*) Production:prod" \
    "( ) Staging:stage")
```

In the example above, the selected item of the form dropdown should be available as `$country` after running `eval "$FORM_OUT"`.

The `=` represents the item which should be selected by default.

Start by looking in the `form()` function, and the `_draw_form_field()` function.

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

