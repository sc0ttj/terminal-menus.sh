# AGENTS.md — terminal-menus.sh

Single-file Pure Bash 3.2+ TUI library (~5,780 lines). Zero dependencies. MIT license.

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

`msgbox`, `infobox`, `yesno`, `inputbox`, `passwordbox`, `menu`, `checklist`, `radiolist`, `filtermenu`, `gauge`, `textbox`, `tailbox`, `tree`, `configtree`, `form`, `filepicker`, `filemanager`, `table`, `filtertable`, `spreadsheet`, `kanban`, `mainmenu`.

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
`TUI_EXTRA_KEYS` — multi-line env var of `key=command` pairs for custom keybindings (see README).

## Testing / verification

All **161 tests pass** in ~64s (down from 165s after bundling PTY sessions per widget class).

```bash
# Run the full demo (exercises every widget):
./terminal-menus-demo.sh

# Run the full test suite:
python3 -m unittest discover -s test -p "test_widget_*.py" -v

# Run a single widget's tests:
python3 -m unittest test.test_widget_msgbox -v

# Run a single test method by filter:
python3 -m unittest discover -s test -p "test_widget_msgbox.py" -k test_msgbox_enter -v

# Run an arbitrary subset by glob:
python3 -m unittest discover -s test -p "test_widget_menu*" -v

# Run only tests affected by uncommitted changes:
./test/run_changed.sh           # run them
./test/run_changed.sh --list    # just list them

# Run under coverage.py (install with `pip install coverage`):
./test/with_coverage.sh

# Run shell compatibility tests (ash and bash syntax + pty functional):
./test/test_shell_compat.sh
```

### Test architecture

- **23 files** (`test/test_widget_*.py`), **161 tests** total.
- Each file tests one widget via PTY-driven integration tests.
- A **persistent ash session** (`PtySession` in `test/testlib.py`) is shared across all test methods in a class via `setUpClass` / `tearDownClass`. Each wrapper runs in a subshell that saves/restores `stty`, keeping terminal state clean between tests. This reduced PTY spawns from 160→23, cutting runtime by 60%.
- Legacy fallback: the `PtyRunner` class (uses `script`) kicks in if `pty.fork()` is unavailable.
- Wrappers: 50 `test/wrappers/*_wrapper.sh` scripts set up the widget and echo `EXIT=` / `RESULT=` markers on stdout.
- The CI pipeline (`.github/workflows/test.yml`) runs the full suite; **ShellCheck** is aspirational (manual, not enforced in CI).
- The demo script (`terminal-menus-demo.sh`) exercises all widgets end-to-end.

### Coverage

```bash
# Line/branch report for terminal-menus.sh:
./test/with_coverage.sh

# HTML report:
./test/with_coverage.sh --html
```

Requires `pip install coverage`. Coverage is currently for monitoring only — no enforcement gate in CI.

## Script conventions

- Functions prefixed with `_` are internal helpers.
- Internal draw helpers: `_draw_at`, `_draw_line`, `_draw_header`, `_draw_footer`, `_draw_btn`, `_draw_list`, `_draw_item`, `_draw_form_field`, `_draw_controls`.
- Terminal cleanup on `EXIT` and `SIGWINCH` via `trap`.
- Use `printf >&2` for rendering to terminal; `stdout` is reserved for widget return data.
- `stty -echo` during TUI; `stty sane` on cleanup.

## Coding Standards

You are an expert Bash developer following the "Bash Bible" philosophy by dylanaraps. Your goal is to write fast, portable, and flicker-free shell scripts and TUIs by avoiding external processes.

### 1. Core Philosophies
- ShellCheck recommended (run manually — not enforced in CI).
- **Pure Bash Only**: Use built-in functionality over external binaries (`sed`, `awk`, `cut`, `basename`, etc.).
- **No Subshells**: Minimize the use of `$(...)` and pipes `|`. Every subshell fork causes TUI flicker.
- **Flicker-Free UI**: 
    - Use ANSI escape codes directly for drawing.
    - Double-buffer output by building strings in variables and printing once using `printf`.
    - Hide the cursor during draws (`\e[?25l`) and show it after (`\e[?25h`).

### 2. BusyBox Ash v1.31.0 Limitations
This project targets BusyBox Ash. Critical incompatibilities with Bash:

| `[[ "$a" == "b"* ]]` glob match | ❌ Use `case "$a" in "b"*)` instead |
| `[[ "$a" == *"b"* ]]` contains | ❌ Use `case "$a" in *"b"*)` instead |
| `[[ "$a" =~ regex ]]` | ❌ Use `case` with glob, or external tool |
| Arrays `a=(x y z)` | ❌ Use `eval`-based numbered vars or `awk` |
| `[[ == literal ]]`, `[[ -z/-n/-d/-f ]]`, `local`, `${var#}`, `$(( ))` | ✅ All work |

**Rule**: Always use `case` for pattern matching, never `[[ ... == ...* ]]`.

### 2b. BusyBox Ash Pitfalls (discovered through bugs)

| Pitfall | Symptom | Fix |
|---|---|---|
| `$(...)` inside `while read < "$tmpf"` | Loop silently skips entries (stdin consumed by subshell) | Use two-phase: read paths from file in one loop with NO subshells, then process in a numbered-index loop |
| `~` in `local dir="$3"` | `~` stays literal, not expanded til home | `dir=$(cd "$dir" && pwd)` resolves to absolute path |
| `result=$(sort <<< "$var")` or `printf "%s" \| sort` | Pipeline via `$(...)` can drop last line under load | Use `sort -o tmpfile tmpfile` for in-place sort |
| Heredocs `<<_EOF_` inside widget functions | Consume from stdin instead of script body in TUI/PTY context | Use temp-file redirection: `while read < "$tmpf"` then `rm -f "$tmpf"` |
| Substring `${var: -3}` (space before minus) | Works in ash but the space before `-3` is required — `: -3` not `:-3` | Always write `${var: -3}` with the space |
| `[[ "$key" == $'\r' ]]` | Prints stderr garbage when `!`, `(`, `=` pressed | Pre-define `cr=$(printf '\r')` and use `[ "$key" = "$cr" ]` |

### 3. System Tool Capabilities (Puppy Linux / current dev environment)

This system uses GNU versions of common tools. Extensions available:

| Tool | Extension | Available |
|------|-----------|-----------|
| **awk** | `gensub()`, `match(str,pat,arr)`, `strtonum()`, `asort()`/`asorti()`, `mktime()`/`strftime()` | ✅ |
| **awk** | `\|&` two-way coprocess | ❌ |
| **date** | `-d "yesterday"`, `+%N` (nanoseconds), `-f` (file input), `-u` (UTC) | ✅ |
| **find** | `-maxdepth`/`-mindepth`, `-regex`, `-delete`, `-newerXY` | ✅ |
| **grep** | `-E`, `-F`, `-P` (PCRE), `-f`, `-o`, `--color`, `--exclude-dir` | ✅ |
| **printf** | `-v` (var assign), `\xHH` (hex), `\uHHHH` (unicode) | ✅ |
| **sed** | `\U`/`\L` case conv, `-E`, `-i [suffix]`, `\n` in replacement | ✅ |
| **tar** | `--auto-compress`/`-a`, `--exclude`, hyphenless `cf` syntax | ✅ |
| **xargs** | `-P` (parallel), `-d` (delimiter), `-0` (null), `-r` (no-run-if-empty) | ✅ |

**Implication**: Generated shell code can safely use GNU extensions. TUI code (`terminal-menus.sh`) must still avoid them for portability to systems with only BusyBox tools.

### 4. Coding Practices & Rules
- **String Manipulation**: Use Parameter Expansion instead of `sed` or `echo | cut`.
    - *Bad*: `name=$(echo "$file" | cut -d. -f1)`
    - *Good*: `name="${file%.*}"`
- **Regex/Matching**: Use `case` statements with glob patterns instead of `grep` or `[[ == pattern ]]`.
- **Reading Files**: Use `read -r` loops; never use `cat` (also `mapfile` is not available in BusyBox Ash).
- **Calculations**: Use `$(( var = a + b ))` for integer math; do not use `bc` or `expr`.
- **Arrays**: Use `eval`-based numbered variables (e.g. `eval "arr_$i='$val'"; eval "v=\$arr_$i"`) since arrays are unavailable.

### 4b. Standard Code Patterns

These patterns are used throughout the codebase and are proven to work on bash 3.2+ and BusyBox Ash:

- **Pattern matching**: Use `_match()` helper — `_match "$var" "pattern*"` — instead of raw `case` when inside a function. Defined as `_match() { case $1 in $2) return 0;; esac; return 1; }`.
- **Key reading**: Always use `_read_key var` (sets `IFS=`, reads `-r -n1` from `/dev/tty`). Use `_read_key_esc` for escape-sequence-aware reading: reads `KEY`, then if ESC, reads `ESC_SEQ`.
- **Escape char**: Pre-define `_escape=$(printf '\e')` at function start rather than calling `printf` inline.
- **Rendering**: ALWAYS use `printf >&2` — never `echo`. Stdout is reserved for widget return data.
- **Terminal setup**: `stty -echo -icanon min 1 time 1` at start of TUI; `stty sane` in cleanup.
- **Modal overlays**: `modal "widget 'arg1' 'arg2'"` layers a dialog on top of a fullscreen widget. Used in CSV command columns for table/mainmenu.
- **External preview override**: `. ./preview.sh` in the demo replaces the built-in `preview()` with an enhanced version. Set `PREVIEW_SCRIPT` env var to auto-load.
- **Theme switching**: Call `_init_static_colors()` then `_init_tui()` to reload colors mid-session after changing `BG_MAIN`, `HL_BLUE`, etc.
- **Temp-file two-phase pattern** (for loops that need subshells):
  ```bash
  # Phase 1: read paths with NO subshells in the body
  while IFS= read -r _fpath < "$tmpf"; do ... done
  # Phase 2: process with numbered-index loop (no stdin redirection)
  i=0; while [ "$i" -lt "$count" ]; do eval "f=\$f_$i"; r=$(_get_fm ...); i=$((i+1)); done
  ```

### 5. TUI Rendering Logic
- **Batch Printing**: Group UI updates into a single `printf` call to prevent partial screen updates.
- **Static Positioning**: Use `\e[H` to return to home and `\e[J` to clear only what is necessary.
- **Colors**: Use variables for ANSI codes: `readonly RED=$'\e[31m'`, `readonly RESET=$'\e[0m'`.

### 6. Color Rendering Rules (CRITICAL)
- **Every visible text element MUST have an explicit foreground color.** Never rely on the terminal's default foreground (which may be black in xterm/Xvfb).
- Use `$FG_TEXT_ESC` (off-white `239;239;239`) as the default foreground for all text unless a specific color is intended.
- When using `$BG_WID_ESC`, `$BG_MAIN_ESC`, or `$BG_INPUT_ESC` (background-only escapes), always pair with a foreground escape like `$FG_TEXT_ESC` or `$FG_BLUE_BOLD`.
- The safe rendering pattern is: `"${BG_XYZ_ESC}${FG_TEXT_ESC} text ${RESET}${BG_MAIN_ESC}"`.
- Escape sequences that are NOT foreground colors: `\e[1m` (bold), `\e[2m` (faint), `\e[22m` (normal intensity). These only modify the existing foreground — they do not set one.
- If adding a new `printf` call that renders visible text, always include a foreground escape BEFORE the text content. The `_draw_line()` and `_draw_at()` helpers now set `$FG_TEXT_ESC` by default, but raw `printf` calls elsewhere must set it explicitly.
- When a text element appears black in screenshots, it means a `printf` somewhere is missing a foreground color. Search for `${BG_WID_ESC}`, `${BG_MAIN_ESC}`, `${BG_INPUT_ESC}`, `${BG_BLUE_ESC}` that are used without a following `${FG_TEXT_ESC}` or other FG escape.

### 7. Screenshot Generation System

#### How screenshots work
Screenshots are generated in isolated Xvfb sessions using `test/interactive_runner.sh` and `scripts/generate_readme_screenshots.sh`.

**Architecture:**
1. `scripts/generate_readme_screenshots.sh` iterates 23 widgets, each wrapped in a `test/wrappers/*_wrapper.sh` script
2. For each widget, it launches `test/interactive_runner.sh` which:
    - Starts Xvfb on a random display (`:99` to `:199`)
    - Launches xterm (`-bw 0 -bg '#222222'` DejaVu Sans Mono 12pt, 100x30) running the wrapper script
    - Finds the xterm window via `xdotool search --classname "xterm"` (--pid fails because xterm forks)
    - Moves xterm to (0,0) so it fills the top-left corner
    - Runs keystroke instructions from `test/drivers/*.driver` to set the widget state
    - Captures the xterm child window (VT100 widget, the pure text area) via `xwd -id` → `convert`
    - Fallbacks: `xwd -id` parent window → full-screen scrot
    - Outputs `[SS] <path>` for the generation script to pick up

**Key components:**
- `test/interactive_runner.sh` — Runner that orchestrates Xvfb + xterm + xdotool + xwd/convert
- `test/wrappers/*_wrapper.sh` — 50 per-widget scripts setting TUI_MODE=fullscreen, BACKTITLE, and demo data (23 used by screenshot generator)
- `test/drivers/*.driver` — 26 per-widget keystroke scripts (send_key, type_text, screenshot, wait_s) (23 used by screenshot generator)
- `scripts/generate_readme_screenshots.sh` — Master generation script that loops all 23 screenshot targets

#### Terminal choice
- **xterm** (not mlterm): chosen for reliable TrueType font support via `-fa`/`-fs` flags
- **Font**: DejaVu Sans Mono 12pt (`xterm -fa 'DejaVu Sans Mono' -fs 12 -geometry 100x30`)
- **Border removal**: `-bw 0` removes the 1px xterm window border; with this, the child window (VT100 widget) offset changes from `+1+1` to `+0+0`
- **Background**: `-bg '#222222'` sets dark grey background matching BG_MAIN (`34;34;34`). Fixes white edges from xterm's default white (#FFFFFF) showing at unpainted areas
- **Do NOT use `-internalBorder 0`**: crashes xterm in Xvfb with BadWindow error
- **Xvfb root window** (`xsetroot -solid`): **not needed** — xterm's own `-bg` handles the background, no white shows around edges
- **Why xterm over mlterm**: xterm supports TrueType fonts via `-fa`/`-fs` and is more widely available. mlterm's default foreground is white (accidentally OK for dark themes) but xterm's default is black — so every BG escape on visible text MUST be paired with a FG escape

#### How to regenerate all screenshots
```bash
rm -f screenshots/*.png
bash scripts/generate_readme_screenshots.sh
```

#### How to regenerate a single screenshot
```bash
# Delete just that one:
rm -f screenshots/mainmenu.png
# Then run the generation script (SKIPs existing ones):
bash scripts/generate_readme_screenshots.sh
```

#### Requirements
- `Xvfb`, `xterm`, `xdotool`, `ImageMagick` (provides `xwd` and `convert`), `ash`, `fonts-dejavu-core`
- `scrot` — optional (last-resort fallback only)

#### Fallback chain for screenshot capture
1. `xwd -id $child_window` + `convert` — captures xterm's VT100 child widget (pure text area, no borders)
2. `xwd -id $parent_window` + `convert` — captures parent window (includes window decorations) if child fails
3. `scrot` (full screen) — last resort if xwd fails

### 8. Troubleshooting Screenshots

**Black text in screenshots:** Missing explicit foreground color in a `printf` call. Fix: add `$FG_TEXT_ESC` before the text content, or use `$HL_WHITE_BOLD` for active/highlighted elements.

**xwd capture fails (no file created):** Run `xwininfo -tree` on the xterm window to verify the child window ID. Increase `sleep 0.5` before the screenshot call in `interactive_runner.sh:screenshot()`. Check that `xwd` and `convert` (ImageMagick) are installed.

**scrot -u fails (no file created):** The xterm window may not be properly focused. The screenshot function falls back to `xwd -id` on the parent window. If scrot consistently fails, check the driver timing (widget may have closed before screenshot). scrot is only the 3rd fallback — xwd is the primary path.

**Window not found error:** `xdotool search --pid` may fail because xterm forks. The runner falls back to `--classname "xterm"`. If both fail, increase the sleep after starting xterm, or try running with DEBUG output visible (remove `2>/dev/null`).

**Persistent color issues after fixes:** Search for `printf` calls that use background-only escapes (`$BG_WID_ESC`, `$BG_MAIN_ESC`, etc.) on visible text without a paired foreground escape. Common locations: `_draw_btn()`, tailbox, mainmenu sidemenu, mainmenu table rows, kanban ticket names, filepicker hidden files, filemanager hidden files.

**White edges around screenshots:** Caused by xterm's default white background (#FFFFFF) at unpainted areas of the terminal. Fix: add `-bg '#222222'` to xterm (matching BG_MAIN `34;34;34`). If re-capturing, delete the old PNG first so the generation script doesn't skip it.

### 9. Debugging

**Shell error detection in tests:** `TuiTestCase.assert_no_shell_errors()` checks PTY output for `"Syntax error"`, `"not found"`, `"Bad substitution"`, `"unknown operand"`, `"closing paren"`. Run tests with `-v` and watch for these.

**The `[[ $'\r' ]]` trap:** In BusyBox Ash, `[[ "$key" == $'\r' ]]` can print to stderr when `!`, `(` or `=` are typed, making those characters appear as visible terminal errors (commit e71d156). Fix: pre-define `cr=$(printf '\r')` and use `[ "$key" = "$cr" ]`. Same for `$'\n'`.

**Tracing with `set -x`:** To debug a widget, temporarily add `set -x` before a problem section and `set +x` after. Shell trace output goes to stderr, which renders as visible text over the TUI. For cleaner capture, redirect stderr to a file: `./terminal-menus.sh 2>/tmp/trace.log` and inspect after.

**No `TUI_DEBUG` env var exists yet.** For surgical tracing, insert `printf "DEBUG: var=$var" >&2` at the point of interest, or wrap with `bash -x terminal-menus.sh 2>/tmp/trace.log`.

**PTY debug timing:** Tests use `PtySession(init_delay=0.05)`. For flaky tests, raise `init_delay=0.3` or fall back to `PtyRunner` (per-test `script` subprocess, slower but more isolated).

**Key constants for tests:**
```python
class KEY:
    ENTER = b"\r"; ESCAPE = b"\x1b"; TAB = b"\t"; SPACE = b" "
    BACKSPACE = b"\x7f"; DELETE = b"\x1b[3~"
    UP = b"\x1b[A"; DOWN = b"\x1b[B"; LEFT = b"\x1b[D"; RIGHT = b"\x1b[C"
    HOME = b"\x1b[H"; END = b"\x1b[F"
    PAGE_UP = b"\x1b[5~"; PAGE_DOWN = b"\x1b[6~"
```

**After code changes:** Always run `bash -n terminal-menus.sh && ash -n terminal-menus.sh` for syntax, then `./test/run_changed.sh` for targeted testing before a full suite run.

### 10. Operational Instructions
- Before writing code, verify if a "Pure Bash" alternative exists for every command you intend to use.
- If a task requires a complex external tool (like `curl`), isolate it and ensure its output is parsed using built-in string manipulation.
- Always check scripts with `shellcheck` (integrated in OpenCode).
- Run `bash -n terminal-menus.sh && ash -n terminal-menus.sh` after every edit.
- Load `shell-fix` skill to fix common bugs (ash compat, color rendering, preview_offset).
- Use `shell-performance` for flicker-free rendering optimization.
- Run `./test/run_changed.sh` for targeted testing before a full suite run.

## 11. Available Skills

These skills are registered in `.opencode/skills/` and are loaded automatically. Use them for common tasks:

| Skill | When to use | What it does |
|---|---|---|
| `screenshots` | Regenerating README screenshots | `rm -f screenshots/*.png && bash scripts/generate_readme_screenshots.sh` |
| `test-widgets` | Running widget integration tests | `python3 -m unittest discover -s test -p "test_widget_*.py" -v` |
| `compat` | Shell compatibility + syntax checks | `bash -n` + `ash -n` + `./test/test_shell_compat.sh` + `python3 test/test_form_pty.sh` |
| `demo` | Running the full interactive demo | `./terminal-menus-demo.sh` |
| `shell-search` | **Searching code** — use `grep`/`ag`, **never `rg`** (not installed) | Patterns for function lookup, variable tracking, color escape hunting |
| `shell-debug` | **Debugging shell code** — tracing, terminal state, syscalls | `bash -x`, `stty`, `strace`, `shellcheck`, TUI debugging checklist |
| `shell-fix` | **Fixing common bugs** — ash compat, color rendering, missing `local`, preview_offset | Pattern catalog for 10 most common bugs in this codebase |
| `shell-performance` | **Optimizing TUI performance** — batch printing, no subshells in loops, pre-computation | Bottleneck checklist for flicker-free rendering |

### Skill invocation

Skills are loaded automatically when their description matches the task. Key rules from `.opencode/skills/shell-search/SKILL.md`:

- **This system has `grep` and `ag` (the Silver Searcher). It does NOT have `rg` (ripgrep). Never use `rg`.**
- Use the search patterns in `shell-search` to find function definitions, variable usage, color escape issues, ash incompatibilities, etc.
- After making changes, always verify with `compat` (`bash -n` + `ash -n`).

