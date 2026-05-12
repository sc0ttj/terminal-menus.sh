# AGENTS.md — terminal-menus.sh

Single-file Pure Bash 3.2+ TUI library (~5k lines). Zero dependencies. MIT license.

## Setup

```bash
source ./terminal-menus.sh     # or . ./terminal-menus.sh
```

## Usage patterns

```bash
# Widget output is captured via subshell AND stored in $TUI_RESULT
CHOICE=$(menu "Title" "Prompt:" 1 "A" "B")
# or run it; then check $TUI_RESULT

# Return values: 0 = OK/selected, 1 = cancelled/error
yesno "Title" "Go?" && echo "yes"
```

## Available widgets

`msgbox`, `infobox`, `yesno`, `inputbox`, `passwordbox`, `menu`, `checklist`, `radiolist`, `filtermenu`, `gauge`, `textbox`, `tailbox`, `tree`, `configtree`, `form`, `file_navigator`, `file_manager`, `table`, `filtertable`, `spreadsheet`, `kanban`, `mainmenu`.

## Layout (set via `TUI_MODE` env var)

`centered` (default), `fullscreen`, `classic`, `popup`, `top`, `bottom`, `toast`, `palette`, `custom`. For `palette`, set `ANCHOR=tl|tr|bl|br|tc|bc|cc`. For `custom`, set `TUI_WIDTH`, `TUI_HEIGHT`, `TUI_X`, `TUI_Y`.

## Theming

Set any of `BG_MAIN`, `BG_MODAL`, `BG_WIDGET`, `BG_ACTIVE`, `HL_BLUE`, `FG_TEXT`, `FG_HINT`, `FG_INPUT`, `BG_INPUT`, `FG_BACKTITLE`, `FG_INPUT_ROOT` before calling a widget, or change them live and call `_init_tui` to reload.

## Modal overlays

```bash
modal "yesno 'Confirm' 'Proceed?'"
```
Used inside table/mainmenu CSV command columns to layer dialogs on fullscreen widgets.

## Other globals

`BACKTITLE`, `OK_LABEL`, `CANCEL_LABEL`, `YES_LABEL`, `NO_LABEL` — customize button text.

## Testing / verification

```bash
# Run the full demo (exercises every widget):
./terminal-menus-demo.sh
```

No test framework, no CI, no linter config. The demo script is the only verification path.

## Script conventions

- Functions prefixed with `_` are internal helpers.
- Internal draw helpers: `_draw_at`, `_draw_line`, `_draw_header`, `_draw_footer`, `_draw_btn`, `_draw_list`, `_draw_item`, `_draw_form_field`, `_draw_controls`.
- Terminal cleanup on `EXIT` and `SIGWINCH` via `trap`.
- Use `printf >&2` for rendering to terminal; `stdout` is reserved for widget return data.
- `stty -echo` during TUI; `stty sane` on cleanup.

## Coding Standards

You are an expert Bash developer following the "Bash Bible" philosophy by dylanaraps. Your goal is to write fast, portable, and flicker-free shell scripts and TUIs by avoiding external processes.

### 1. Core Philosophies
- Use ShellCheck for all Bash scripts.
- **Pure Bash Only**: Use built-in functionality over external binaries (`sed`, `awk`, `cut`, `basename`, etc.).
- **No Subshells**: Minimize the use of `$(...)` and pipes `|`. Every subshell fork causes TUI flicker.
- **Flicker-Free UI**: 
    - Use ANSI escape codes directly for drawing.
    - Double-buffer output by building strings in variables and printing once using `printf`.
    - Hide the cursor during draws (`\e[?25l`) and show it after (`\e[?25h`).

### 2. Coding Practices & Rules
- **String Manipulation**: Use Parameter Expansion instead of `sed` or `echo | cut`.
    - *Bad*: `name=$(echo "$file" | cut -d. -f1)`
    - *Good*: `name="${file%.*}"`
- **Regex/Matching**: Use `[[ $var =~ regex ]]` or `case` statements instead of `grep`.
- **Reading Files**: Use `mapfile -t` or `read -r` loops; never use `cat`.
- **Calculations**: Use `(( var = a + b ))` for integer math; do not use `bc` or `expr`.
- **Arrays**: Use indexed and associative arrays for state management to avoid temp files.

### 3. TUI Rendering Logic
- **Batch Printing**: Group UI updates into a single `printf` call to prevent partial screen updates.
- **Static Positioning**: Use `\e[H` to return to home and `\e[J` to clear only what is necessary.
- **Colors**: Use variables for ANSI codes: `readonly RED=$'\e[31m'`, `readonly RESET=$'\e[0m'`.

### 4. Operational Instructions
- Before writing code, verify if a "Pure Bash" alternative exists for every command you intend to use.
- If a task requires a complex external tool (like `curl`), isolate it and ensure its output is parsed using built-in string manipulation.
- Always check scripts with `shellcheck` (integrated in OpenCode).

