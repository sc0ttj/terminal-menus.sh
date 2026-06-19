# terminal-menus.sh

A high-performance, dependency-free TUI (Terminal User Interface) library, supports **Bash 3.2+** and **BusyBox Ash** (with `ASH_BASH_COMPAT` enabled), with `whiptail` and `dialog` style widgets, and more modern, fancier ones too.

Inspired by the `dylanaraps` philosophy, `terminal-menus.sh` provides a modern alternative to `whiptail` and `dialog` with support for TrueColor and modular layouts.

See the demos :) 

## Screenshots

Screenshots of each widget are included throughout this document, alongside their descriptions.

The **`filemanager`** in fullscreen mode:

![filemanager](screenshots/filemanager.png)

The **`mainmenu`** in fullscreen mode:

![mainmenu](screenshots/mainmenu.png)

---

## 🚀 Features

- **Bash 3.2+ & BusyBox Ash**: Works on old, modern & embedded systems (Mac and Linux).
- **Zero Dependencies**: No `dialog`, `ncurses`, or `python` required.
- **TrueColor (24-bit)**: Customisable RGB themes.
- **Many Layouts**: Modal popups, full-screen UIs, toast notifications, and command palettes.
- **High Performance**: Pre-computed lowercase caches, viewport file reading (no `sed` per row), `find`-based directory listing (no shell glob ARG_MAX), shell parameter expansion over `awk`/`cut`/`tr` forks, and `MAX_FILTER_ITEMS` safety cap.

> **Shell requirements**: The library requires `[[ ]]`, `read -n`, and `$'...'` support.  
> Bash 3.2+ works natively. BusyBox Ash needs `ASH_BASH_COMPAT` enabled at build time.  
> The library checks these on startup and exits with a clear error if any are missing.

---

## 📦 Installation

Simply source the script:

```bash
. ./terminal-menus.sh     # Portable (ash, bash)
source ./terminal-menus.sh  # Bash-specific
```

---

## 🎮 Demo Script

The included demo script (`terminal-menus-demo.sh`) exercises every widget. Three ways to use it:

```bash
./terminal-menus-demo.sh                # Interactive widget picker menu
./terminal-menus-demo.sh all            # Run all 23 demos sequentially
./terminal-menus-demo.sh filemanager    # Run one widget demo and exit
```

Valid widget names: `infobox`, `msgbox`, `yesno`, `inputbox`, `passwordbox`, `menu`, `checklist`, `radiolist`, `filtermenu`, `gauge`, `textbox`, `tailbox`, `tree`, `configtree`, `form`, `filepicker`, `table`, `filtertable`, `filemanager`, `spreadsheet`, `kanban`, `mainmenu`.

When run with no arguments, the script shows a `filtermenu` listing all widgets. Select "All widgets" to run everything in order, or pick individual widgets to run one at a time (returns to the picker after each).

---

## 🛠 Basic Usage
### 1. Message Box (`msgbox`)

![msgbox](screenshots/msgbox.png)

Displays a standard modal with an OK button.

**Environment Variables:**
- `OK_LABEL` — Custom OK button text (default: `"OK"`)
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode (centered, fullscreen, classic, popup, top, bottom, toast, palette)

**Controls:**
- **Enter** — Confirm / Close

```bash
OK_LABEL="Let's Go!"
msgbox "Welcome" "This is a standard message box.\nEnjoy!"
```

### 2. Info Box (`infobox`)

![infobox](screenshots/infobox.png)

A non-blocking message window without buttons. Ideal for background tasks.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

```bash
infobox "Processing" "I'm an infobox.\nI show messages without buttons."
sleep 2
```

### 3. Yes/No Menu (`yesno`)

![yesno](screenshots/yesno_theme.png)

Standard boolean choice. Includes support for default focus (1 for Yes, 2 for No).

**Environment Variables:**
- `YES_LABEL` — Custom Yes button text (default: `"YES"`)
- `NO_LABEL` — Custom No button text (default: `"NO"`)
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Left** / **Right** — Switch focus between Yes/No
- **Enter** — Confirm selection
- **Esc** — Cancel (returns exit code 1)

```bash
if yesno "Question" "Do you want to continue?" 2; then
    echo "User chose Yes"
fi
```

### 4. Input Box (`inputbox`)

![inputbox](screenshots/inputbox.png)

Captures a single line of text from the user.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode
- `TUI_RESULT` — Empty string on cancel

**Controls:**
- **Left** / **Right** — Move cursor within input
- **Backspace** — Delete character before cursor
- **Enter** — Confirm input
- **Esc** — Cancel (returns empty, sets `TUI_RESULT=''`)

```bash
USER_NAME=$(inputbox "Identity" "Enter your username:" "foo")
```

### 5. Password Box (`passwordbox`)

![passwordbox](screenshots/passwordbox.png)

Masked input for sensitive tokens or passwords.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode
- `TUI_RESULT` — Empty string on cancel

**Controls:**
- **Enter** — Confirm input
- **Esc** — Cancel (returns empty, sets `TUI_RESULT=''`)

```bash
PASS=$(passwordbox "Security" "Enter a secret token:" "ppp")
```

### 6. Menu (`menu`)

![menu](screenshots/menu.png)

A standard single-choice selection list. Also see `filtermenu`.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Up** / **Down** or **k** / **j** — Navigate
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Enter** — Select highlighted item
- **q** — Cancel / Quit

```bash
CHOICE=$(menu "Simple Menu" "Pick a fruit:" 2 "Apple" "Banana" "Cherry")
```

For large item sets, use `--file` to read items from a file (avoids ARG_MAX):
```bash
CHOICE=$(menu "Menu" "Pick one:" --file /path/to/items.txt)
```

### 7. Checklist (`checklist`)

![checklist](screenshots/checklist.png)

Multiple-choice selection list. Returns each selected item on a new line.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Up** / **Down** or **k** / **j** — Navigate
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Space** — Toggle selection for current item
- **Enter** — Confirm and return all selected items
- **q** — Cancel / Quit

```bash
CHKS=$(checklist "Checklist" "Select multiple options:" 2 "Option 1" "Option 2" "Option 3")
```

For large item sets, use `--file` to read items from a file (avoids ARG_MAX):
```bash
CHKS=$(checklist "Checklist" "Select:" --file /path/to/items.txt)
```

### 8. Radiolist (`radiolist`)

![radiolist](screenshots/radiolist.png)

Mutually exclusive selection list.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Up** / **Down** or **k** / **j** — Navigate
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Space** — Select current item
- **Enter** — Confirm selection
- **q** — Cancel / Quit

```bash
RADIO=$(radiolist "Radiolist" "Choose exactly one:" 2 "Low" "Medium" "High")
```

For large item sets, use `--file` to read items from a file (avoids ARG_MAX):
```bash
RADIO=$(radiolist "Radiolist" "Choose:" --file /path/to/items.txt)
```
```

### 9. Filtermenu (`filtermenu`)

![filtermenu](screenshots/filtermenu.png)

A searchable, real-time filtered list for large datasets.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Type** — Filter list in real-time
- **Up** / **Down** or **k** / **j** — Navigate filtered results
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Left** / **Right** — Move cursor within filter input
- **/** — Focus filter input (from list)
- **Backspace** — Delete last filter character; when empty, focuses filter
- **Down** — Focus first list item (from filter)
- **Enter** — Select highlighted item
- **q** — Cancel / Quit (when not in filter input)

```bash
COUNTRIES="Argentina\nAustralia\nBrazil\nCanada"
SEARCH=$(filtermenu "Search" "Type to filter:" 1 "$COUNTRIES")
```

### 10. Gauge (`gauge`)

![gauge](screenshots/gauge.png)

Visual progress bar tracking piped input (0-100).

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

```bash
( for i in {0..100..20}; do echo $i; sleep 0.3; done ) | gauge "Deploying" "Working..."
```

### 11. Textbox (`textbox`)

![textbox](screenshots/textbox.png)

A read-only scrollable file viewer.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Up** / **Down** or **j** / **k** — Scroll vertically
- **Page Up** / **Page Down** or **[** / **]** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Enter** — Close viewer

```bash
textbox "Source view" "File: terminal-menus.sh" "./terminal-menus.sh"
```

### 12. Tailbox (`tailbox`)

![tailbox](screenshots/tailbox.png)

Live-monitoring of a file (similar to `tail -f`).

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Enter** — Close viewer

```bash
tailbox "Log Monitor" "File: server.log" "server.log"
```

### 13. Tree (`tree`)

![tree](screenshots/tree.png)

Deep hierarchical navigation. Returns the full path from root of the selected node. Optional search/filter input.

**Environment Variables:**
- `ENABLE_FILTER` — Set to `true` to show a search/filter input (default: `false`)
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Up** / **Down** — Navigate tree
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Left** / **Right** — Collapse / Expand nodes
- **Enter** — Select node (returns full path from root)
- **Space** — Toggle selection (config mode only)
- **/** — Focus filter input (when `ENABLE_FILTER=true`)
- **Tab** — Toggle focus between filter and tree (when `ENABLE_FILTER=true`)
- **q** — Quit

```bash
TREE_DATA=("0|usr|/usr|true" "1|bin|bin/|true" "2|bash|bash|false")
TREE_RES=$(ENABLE_FILTER=true tree "Browser" "Select path:" 1 "${TREE_DATA[@]}")
```

For large tree data, use `--file` to read nodes from a file (one node per line, avoids ARG_MAX):
```bash
TREE_RES=$(ENABLE_FILTER=true tree "Browser" "Select path:" --file /path/to/nodes.txt)
```

### 14. Configtree (`configtree`)

![configtree](screenshots/configtree.png)

Hierarchical configuration toggle. Returns a list of variable assignments. Optional search/filter input. Children of unchecked parents are automatically excluded.

**Environment Variables:**
- `ENABLE_FILTER` — Set to `true` to show a search/filter input (default: `false`)
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Up** / **Down** — Navigate tree
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Left** / **Right** — Collapse / Expand nodes
- **Space** — Toggle checkbox value
- **Enter** — Confirm and return variable assignments
- **/** — Focus filter input (when `ENABLE_FILTER=true`)
- **Tab** — Toggle focus between filter and tree (when `ENABLE_FILTER=true`)

```bash
CONFIG_OUT=$(ENABLE_FILTER=true configtree "Settings" "Configure System" 1 "${CONFIG_DATA[@]}")
```

For large tree data, use `--file` to read nodes from a file (avoids ARG_MAX):
```bash
CONFIG_OUT=$(ENABLE_FILTER=true configtree "Settings" "Configure System" --file /path/to/nodes.txt)
```

### 15. Form (`form`)

![form](screenshots/form.png)

Advanced form builder. Returns shell-evaluable assignments.

**Field Types:**
- `> Label:var=default` — Text input
- `>* Label:var=default` — Password input (masked)
- `[ ] Label:var` — Checkbox, use `[x]` for checked
- `( ) Label:var` — Radio, use `(*)` for selected
- `{ } display1:val1,=default:val2,...` — Dropdown menu (`=` marks default)
- `---` — Visual separator

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Tab** — Cycle through interactive fields
- **Up** / **Down** — Navigate between fields
- **Left** / **Right** — Move cursor in text/password inputs
- **Space** — Toggle checkbox/radio, open/close dropdown
- **Enter** — Submit form
- **q** — Cancel / Quit
- **Esc** — Close dropdown or cancel

**Dropdown Specifics:**
- When a dropdown is open, **Up** / **Down** navigates options
- **Space** selects the highlighted option and closes the dropdown
- Option values are extracted from the last `:` in `display:value`

```bash
FORM_OUT=$(form "Provisioning" "Node" \
    "> User:user=guest" \
    ">* Password:password" \
    "Country:" \
    "{ } United Kingdom:uk,=USA:usa,South Africa:southafrica" \
    "[x] Wifi:wlan0" \
    "(*) Prod:prod")
eval "$FORM_OUT"
```

### 16. File Picker (`filepicker`)

![filepicker](screenshots/filepicker.png)

A lightweight file and directory picker, supports picking single or multiple items. Also see `filemanager`.

**Environment Variables:**
- `TUI_CD_FILE` — File path to write `cd "dir"` commands to (for external shell integration)
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Up** / **Down** or **k** / **j** / **w** / **s** — Navigate
- **Enter** or **Right** or **l** / **d** — Open directory / Select file
- **Left** or **h** / **a** — Go to parent directory
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Tab** — Toggle mark on current item (for multiple selection)
- **.** — Toggle hidden files
- **q** — Cancel / Exit

```bash
FILE_PICK=$(filepicker "File picker" "Choose a file" "." 2)
```

### 17. Table (`table`)

![table](screenshots/table.png)

Navigable table from CSV. Returns the command or text in the last (hidden) column of the selected row.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Up** / **Down** or **k** / **j** — Scroll rows
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Enter** — Select row (returns last column value)
- **q** — Cancel / Quit

```bash
RESULT_CMD=$(table "Action Center" "Pick an item" "data.csv" 1)
```

### 18. Filtertable (`filtertable`)

![filtertable](screenshots/filtertable.png)

Filterable table from CSV. Returns the command or text in the last (hidden) column of the selected row.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Type** — Filter rows in real-time
- **Up** / **Down** or **k** / **j** — Scroll filtered results
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Enter** — Select row (returns last column value)
- **Backspace** — Delete last filter character (when empty, exits widget)
- **q** — Cancel / Quit (when not in filter input)
- **Esc** — Cancel / Exit

```bash
RESULT_CMD=$(filtertable "Service Search" "Type to search, pick an item." "services.csv" 1)
```

### 19. File Manager (`filemanager`)

![filemanager](screenshots/filemanager.png)

A fast, full-featured file manager, with search & filter, file previews, multiple select, command prompts, and more.

**Controls:**

```
[Arrows]  Navigate (also w/a/s/d and h/j/k/l)
[ENTER]   Open / Select
[TAB]     Toggle add to selection (sel/{})
[SPACE]   Toggle current selection
[.]       Toggle hidden files
[,]       Toggle detailed list
[i]       Toggle ignored (.gitignore)
[/]       Search filter
[:/!]     Shell prompt (! for root)
[sel/{}]  Current selection in prompt
[e]       Edit file in $EDITOR
[f/F]     New file (f) or folder (F)
[r]       Rename item
[x/c/v]   Cut/copy/paste
[PgUp] / [PgDn]   Scroll by page
[Home] / [End]    Jump to top / bottom
[~]       Go home
[?]       Show help
[[]/[]]   Preview scroll up/down
[q/ESC]   Exit / Cancel
```

**Notes:**
- **TAB selections persist** across view toggles (`,`), directory changes, and cross-directory navigation. Select files in one directory, navigate to another, and TAB-select more — all selections are returned on exit.
- **Tab** highlights selected items in yellow. Selected items remain highlighted when switching between normal and detailed list views.

**Usage:**

```bash
filemanager "Home" "$HOME"
```

You can highlight multiple items using **Tab**, and hit **`:`** to launch a command prompt (**`!`** for root prompt), and then run `rm {}` or `rm sel` to delete the selected files.

**`TUI_CD_FILE` integration** — Use `filemanager` as a "cd on exit" directory picker:

```bash
export TUI_CD_FILE=/tmp/tui_cd.txt
filemanager "Browse" "$HOME"
if [ -f "$TUI_CD_FILE" ]; then
    cd "$(cat "$TUI_CD_FILE")"
fi
```

### 20. Spreadsheet (`spreadsheet`)

![spreadsheet](screenshots/spreadsheet.png)

An Excel-like sheet, supports formulas (SUM|AVG|MIN|MAX|COUNT|COUNTA|ROUND|CONCAT|IF), horizontal/vertical scrolling, and undo/redo.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Arrows** or **w** / **a** / **s** / **d** — Navigate cells
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to first / last cell
- **Enter** — Enter edit mode for current cell
- **Right** / **Left** — Move cursor in edit mode
- **?** — Toggle help popup (lists all expressions)
- **q** — Quit

```bash
FINAL_DATA=$(spreadsheet "budget.csv")
```

### 21. Project Manager (`kanban`)

![kanban](screenshots/kanban.png)

A multi-column kanban board, with a searchable table view.

**Environment Variables:**
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Arrows** or **w** / **a** / **s** / **d** — Navigate
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **W** / **A** / **S** / **D** or **H** / **J** / **K** / **L** — Move item
- **/** — Search items
- **o** — Cycle sort (by rank, modified, created, completed)
- **O** — Toggle ascending / descending
- **Enter** or **e** — Edit note in `$EDITOR`
- **n** — New note
- **t** — Append tag
- **z** — Undo
- **Z** — Redo
- **q** — Quit

```bash
kanban "Awesome Project" "Manage notes & tickets" ./some-folder
```

### 22. Main Menu (`mainmenu`)

![mainmenu](screenshots/mainmenu.png)

A sidebar menu on the left, where each menu item loads a navigable table, which can launch commands and other widgets.

**Environment Variables:**
- `TUI_PERSISTENT_FILTERS` — Set to `true` to retain filter text when switching sidebar items
- `BACKTITLE` — Background title text
- `TUI_MODE` — Layout mode

**Controls:**
- **Tab** — Toggle focus between sidebar and table
- **Up** / **Down** or **k** / **j** — Navigate sidebar or table
- **Left** / **Right** — Switch focus to sidebar / table
- **Page Up** / **Page Down** — Scroll by page
- **Home** / **End** — Jump to top / bottom
- **Enter** — Select item, or run command from selected table row
- **/** — Focus filter input (when in table view)
- **Backspace** — Focus filter input
- **1-9** — Sort table by column N (press same key again to toggle asc/desc)
- **q** — Quit (when focus is on sidebar or table; types `q` if in filter input)

```bash
mainmenu "Media Center" "Select category" "$MENU_CFG" 1
```

---

## 🖼 Advanced Features

### 🎨 Layout Modes (`TUI_MODE`)

The library uses a global `TUI_MODE` variable to determine the geometry and placement of widgets.
You can change this on the fly between widget calls to create dynamic interfaces.

#### Standard Layouts
- **`centered`** (Default): A balanced box (74x22) centered on the screen.
- **`fullscreen`**: Occupies the entire terminal area. Best for `filemanager` and `mainmenu`.
- **`classic`**: A standard 80x25 terminal box centered for a nostalgic feel.
- **`popup`**: A small (50x7) high-focus modal for quick alerts or single inputs.

#### Edge-Anchored Layouts
- **`top`**: A full-width bar (10 rows high) at the very top of the terminal.
- **`bottom`**: A full-width bar (10 rows high) snapped to the bottom edge.

#### Floating & HUD Layouts
- **`toast`**: A slim notification box (35x4) snapped to the **top-right** corner.
- **`palette`**: A versatile "Command Palette" that uses the `ANCHOR` variable for placement.

#### `ANCHOR` (For `palette` mode)
When using `palette`, set the `ANCHOR` environment variable to a two-letter code:
- **`tl` / `tr`**: Top-Left / Top-Right
- **`bl` / `br`**: Bottom-Left / Bottom-Right
- **`tc` / `bc`**: Top-Center / Bottom-Center
- **`cc`**: Dead Center

#### Examples

**A standard centered question:**
```bash
TUI_MODE="centered" yesno "Title" "Do you want to proceed?"
```

**A quick notification toast that disappears after 3 seconds:**
```bash
TUI_MODE="toast" infobox "System" "Backup completed successfully." && sleep 3
```

**A command palette anchored to the bottom-right:**
```bash
TUI_MODE="palette" ANCHOR="br" menu "Actions" "Rebuild" "Deploy" "Quit"
```

**A full-screen dashboard:**
```bash
TUI_MODE="fullscreen" BACKTITLE="Server Monitor" mainmenu "Dashboard" "Select Tool" "$MENU_CFG"
```

---

### 🎨 Theme Customisation & Live Reloading

The library uses a set of global variables for its TrueColor (24-bit RGB) palette. You can change these at any time to create custom themes or dark/light mode toggles.

#### Global Colour Variables
- `BG_MAIN`: The main background of the widget window.
- `BG_WIDGET`: The background for buttons, list items, and inputs.
- `BG_ACTIVE`: The primary focus/highlight colour (Deep Blue by default).
- `FG_TEXT`: The primary text colour.
- `FG_HINT`: Dimmed text for footer controls and shortcuts.
- `BG_INPUT`: Near-black background for text input fields.

#### Modals Background
- `BG_MODAL`: Override the dimmed modal background (default: `"50;50;50"`).

#### Live Reloading a Theme
To change the theme on the fly, update the variables and then call `_init_tui`. This is useful for "Settings" menus that apply changes immediately without restarting the script.

```bash
# Define a 'Midnight' theme
set_midnight_theme() {
    BG_MAIN="10;20;30"      # Very dark blue
    BG_WIDGET="30;40;50"    # Muted blue-grey
    HL_BLUE="0;255;255"     # Cyan selection
    
    # Reload the TUI engine to apply changes
    _init_tui 
}

# Example: Change theme based on user choice
if yesno "Theme Switcher" "Switch to Midnight mode?"; then
    set_midnight_theme
fi
```

#### Mapping Highlights
The variable `HL_BLUE` is an alias for `BG_ACTIVE`. When you update one, the library automatically re-calculates the bold and inverted ANSI sequences during the next `_init_tui` call, ensuring all widgets (menus, checklists, etc.) stay visually consistent.

---

### 🖼 Modal Dialogs in Fullscreen
A key feature of this library is the ability to launch **Modal Widgets** on top of a "parent" fullscreen widget (like `mainmenu` or `filemanager`). This creates a layered, "desktop-like" experience without losing the state of the background application.

To achieve this, use the `modal` wrapper. This automatically handles background dimming, state preservation, and terminal cleanup.

#### Using the `modal` Wrapper
The `modal` function tells the library to "faint" the background and treat the next widget as a temporary overlay.

```bash
# Inside a script or a CSV command:
modal "yesno 'Playback' 'Resume from last seen?'"
```

This is most powerful when used in the `Command` column of your `table` or `mainmenu` CSVs:

```csv
Item,Category,Command
Settings,System,modal "form 'Settings' 'Edit User' '> User:u'"
Delete,Action,modal "yesno 'Confirm' 'Are you sure?'" && rm file.tmp
```

---

### ⌨️ Custom Keybindings (`TUI_EXTRA_KEYS`)

Add custom keyboard shortcuts to any interactive widget. Bind a key to arbitrary shell code — typically a `modal` call — to overlay popups without leaving the current widget.

**Format:** one `key=command` per line in the env var.

| Key syntax | Example | Effect |
|------------|---------|--------|
| Literal char | `?=modal "infobox 'Help' '...'"` | Triggers on `?` |
| `ctrl_<c>` | `ctrl_x=modal "yesno 'Quit?' '...'"` | Control+X |
| `shift_<c>` | `shift_u=modal "msgbox '…'"` | Uppercase U |

**Controls:**
- Keys are checked **before** the widget's native handler, so you can shadow built-in keys.
- The value is any shell code (typically `modal "widget 'title' 'body'"`).
- Control codes use `_` separator: `ctrl_c`, `ctrl_x`, etc.
- Single quotes inside values are automatically escaped; avoid unescaped double quotes in message text.

**Example — filemanager with help, info, and about modals:**

```bash
export TUI_EXTRA_KEYS="
shift_u=modal \"msgbox 'Help' 'Navigate with arrows/j/k.\nTab to select.\nq to quit.'\"
2=modal \"infobox 'System Info' 'terminal-menus.sh v1.0'\"
3=modal \"msgbox 'About TUI_EXTRA_KEYS' 'Set TUI_EXTRA_KEYS env var with:\n  key=command\n  ctrl_x=command'\"
"
filemanager "Browse" "$HOME"
```

Works in all 16 interactive widgets: `menu`, `checklist`, `radiolist`, `msgbox`, `yesno`, `inputbox`, `passwordbox`, `textbox`, `tailbox`, `form`, `spreadsheet`, `filtermenu`, `filepicker`, `tree`/`configtree`, `table`/`filtertable`, `mainmenu`, `filemanager`, `kanban`.

---

## ⚙️ Persistent Configuration

The `mainmenu` demo includes a `update_config` helper to manage `key=value` configuration files with automatic duplicate removal:

```bash
# Saves 'theme=dark' to your config file
update_config "theme='dark'"
```

### Useful Environment Variables

| Variable | Widget | Purpose |
|----------|--------|---------|
| `TUI_PERSISTENT_FILTERS=true` | `mainmenu` | Keep filter text when switching sidebar items |
| `ENABLE_FILTER=true` | `tree`, `configtree` | Enable search/filter input |
| `TREE_RETURN_VALUES=true` | `tree` | Return label paths instead of ID paths |
| `TUI_CD_FILE` | `filepicker`, `filemanager` | Write `cd` commands to a file for shell integration |
| `TUI_MODE` | All | Layout mode (centered, fullscreen, classic, popup, top, bottom, toast, palette) |
| `TUI_WIDTH` / `TUI_HEIGHT` | `custom` mode | Custom widget dimensions |
| `TUI_X` / `TUI_Y` | `custom` mode | Custom widget position |
| `BACKTITLE` | All | Background title text |
| `OK_LABEL` | `msgbox` | OK button label |
| `YES_LABEL` / `NO_LABEL` | `yesno` | Yes/No button labels |
| `TUI_EXTRA_KEYS` | All interactive widgets | Custom keybindings (see [Custom Keybindings](#-custom-keybindings-tui_extra_keys)) |
| `MAX_FILTER_ITEMS` | `mainmenu`, `filtermenu`, `filtertable`, `tree`, `configtree` | Max items to process in filter loops (default: 5000). Prevents freezes with 10K+ items |
| `BG_MODAL` | `modal` wrapper | Modal overlay background colour |
| `ANCHOR` | `palette` mode | Anchor position (tl, tr, bl, br, tc, bc, cc) |

---

## 🧪 Testing

Tests live in `test/`. Four types available:

### 1. Shell compatibility tests (no X required)

```bash
./test/test_shell_compat.sh
```

Checks syntax (`ash -n`, `bash -n`) on both scripts, runs the pty form test under each shell, and executes all widget integration tests.

Widget integration tests use `ash` by default. To run under a specific shell:

```bash
cd test && python3 -m unittest test_demo_widgets
cd test && SHELL=bash python3 -m unittest test_demo_widgets
cd test && SHELL=ash  python3 -m unittest test_demo_widgets
```

### 2. Widget integration tests (no X required)

Run all 92 tests across 22 widgets:

```bash
cd test && python3 -m unittest test_demo_widgets -v
```

Run a single widget's tests:

```bash
python3 -m unittest test.test_demo_widgets.TestMenu
python3 -m unittest test.test_demo_widgets.TestForm.test_full_flow
```

Widgets covered: `menu`, `checklist`, `radiolist`, `msgbox`, `yesno`, `inputbox`, `passwordbox`, `textbox`, `tailbox`, `form`, `infobox`, `gauge`, `spreadsheet`, `filtermenu`, `filepicker`, `tree`, `configtree`, `table`, `filtertable`, `filemanager`, `mainmenu`, `kanban`.

### 3. Pty-based functional test (no X required)

```bash
python3 test/test_form_pty.sh
```

Validates form widget output — 7 assertions on checkbox states, radio selection, dropdown default, and password field. To run under a specific shell:

```bash
SHELL=ash  python3 test/test_form_pty.sh
SHELL=bash python3 test/test_form_pty.sh
```

### 4. X-based visual tests (requires Xvfb, xterm, xdotool, scrot)

All commands run from the project root:

```bash
# Form visual test — opens form, submits with Enter, captures 2 screenshots
cd test && ash interactive_runner.sh wrappers/form_test.sh drivers/form_test.driver

# Mainmenu visual test — Tab/Enter modal flow, types text, submits, quits (4 screenshots)
cd test && ash interactive_runner.sh wrappers/mainmenu_test.sh drivers/mainmenu_test.driver

# Full 23-widget demo — automates all widgets in terminal-menus-demo.sh (~24 screenshots)
cd test && ash interactive_runner.sh wrappers/full_demo_wrapper.sh test_full_demo.sh
```

Screenshots are written to `/tmp/tui_tests/<timestamp>/`.

### CI

The project ships with a GitHub Actions workflow (`.github/workflows/test.yml`) that runs
syntax checks, form pty test, and all widget integration tests on every push/PR.

### Test structure

| Path | Purpose |
|------|---------|
| `test/testlib.py` | `PtyRunner`, `TuiTestCase`, `KEY` constants — shared PTY test framework |
| `test/test_demo_widgets.py` | Python integration test module covering all 22 widgets (92 tests) |
| `test/wrappers/` | Shell wrappers that source the library and invoke each widget |
| `test/interactive_runner.sh` | Harness: starts Xvfb, launches xterm, sources driver, sends keystrokes |
| `test/test_shell_compat.sh` | Shell compatibility test runner — ash + bash syntax and pty functional |
| `test/test_form_pty.sh` | Python pty-based form output test (supports `SHELL=ash` / `SHELL=bash`) |
| `test/test_full_demo.sh` | Keystroke driver for the full 23-widget demo |
| `test/drivers/` | Keystroke command scripts sourced by the harness |

---

## 📜 License

Copyright (c) 2026 sc0ttj
Licensed under the MIT License:  
[https://opensource.org](https://opensource.org)
