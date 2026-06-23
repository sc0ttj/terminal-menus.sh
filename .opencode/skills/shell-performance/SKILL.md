---
name: shell-performance
description: Optimize shell script performance for flicker-free TUI rendering. Use when writing or reviewing rendering code, loop-heavy logic, or any code path that runs during a TUI frame draw.
---

# Shell Performance

Every millisecond counts during TUI frame rendering. Subshell forks and per-iteration `printf` calls cause visible flicker.

## Rule 0: Profile first

```bash
# Time a widget invocation
time bash -c 'source ./terminal-menus.sh; TUI_MODE=fullscreen _init_tui'

# Count subshells in a render loop (look for $(), |, backticks)
grep -n '\$(\||`' terminal-menus.sh | grep -i 'while\|for\|draw\|render\|preview'
```

## 1. Batch printing: build string, print once

**Bad** — N `printf` calls, N cursor moves:
```bash
i=0; while [ "$i" -lt "$height" ]; do
    _draw_at "$row"
    printf "  %s" "$item" >&2
    i=$((i+1))
done
```

**Good** — single `printf "%b"`:
```bash
local buf=""
i=0; while [ "$i" -lt "$height" ]; do
    local r=$((row + i + PADDING_TOP))
    local c=$((PADDING_LEFT + COL_START))
    buf="${buf}"$'\033'"[$((r));${c}H  ${item}"
    i=$((i+1))
done
printf "%b" "$buf" >&2
```

**Reference:** `preview()` (lines 148-176) builds `clear_block` in a string, prints once at line 154, then builds `preview_content` and prints once at line 176. `_init_tui` (lines 271-280) builds the full wall in one string and prints once.

## 2. No subshells in render loops

Every `$(...)` or backtick creates a child process. Invisible in isolation, catastrophic at 50+ iterations per frame.

**Bad:**
```bash
while ...; do
    display_val=$(printf '%*s' "${#value}" '' | tr ' ' '*')
    row_str=$(printf "\e[%d;%dH%s" "$r" "$c" "$label")
done
```

**Good:**
```bash
# Pre-compute outside the loop:
local dots; dots=$(printf '%*s' "${#value}" '' | tr ' ' '*')

# Build escape sequences via string concat, not command sub:
buf="${buf}"$'\033'"[$((r));${c}H${label}"
```

**Anti-pattern in this codebase:** `preview()` line 170 runs `row_str=$(printf ...)` inside a `while read` loop — each iteration forks. Fix: use `$'\033'[...]` string concat instead.

## 3. Parameter expansion over external tools

Never use `sed`, `cut`, `tr`, `grep`, `awk`, `basename`, `dirname` in a render loop.

| Operation | Fork (slow) | Pure shell (fast) |
|---|---|---|
| Remove suffix | `echo "$var" \| sed 's/foo$//'` | `"${var%foo}"` |
| Remove prefix | `echo "$var" \| cut -d. -f2-` | `"${var#*.}"` |
| Replace char | `echo "$var" \| tr ' ' '_'` | `"${var// /_}"` |
| Basename | `basename "$path"` | `"${path##*/}"` |
| Dirname | `dirname "$path"` | `"${path%/*}"` |
| Substring | `echo "$var" \| cut -c1-5` | `"${var:0:5}"` |
| Lowercase | `echo "$var" \| tr A-Z a-z` | `"${var,,}"` (bash) or `_tolower` helper |
| Arithmetic | `expr $a + $b` | `$((a + b))` |

## 4. Read files without cat/pipe

**Bad:** `cat file | while read line; do ... done` — 3 forks (cat, pipe, while subshell)

**Good:** `while IFS= read -r line; do ... done < file` — 0 forks

## 5. Avoid pipes in loops

**Bad:**
```bash
for item in $list; do
    echo "$item" | grep -q "pattern" && do_thing
done
```

**Good:**
```bash
for item in $list; do
    case "$item" in *pattern*) do_thing ;; esac
done
```

## 6. Pre-compute reusable strings

**Bad** (re-computed every frame):
```bash
_draw_footer() {
    local current_row=$row
    while [ "$current_row" -lt "$MAX_HEIGHT" ]; do
        _draw_at "$current_row"
        printf "%*s" "$MAX_WIDTH" "" >&2
        current_row=$((current_row+1))
    done
}
```
This is in this codebase at lines 495-501. Each call loops up to `MAX_HEIGHT` times with a `printf` fork per iteration.

**Good:**
```bash
# Pre-compute once at init:
local _blank_line; _blank_line=$(printf "%*s" "$MAX_WIDTH" "")

# Then just replay:
_draw_footer() {
    local cr=$row
    while [ "$cr" -lt "$MAX_HEIGHT" ]; do
        local r=$((cr + PADDING_TOP))
        local c=$((PADDING_LEFT + COL_START))
        buf="${buf}"$'\033'"[$((r));${c}H${_blank_line}"
        cr=$((cr+1))
    done
}
```

**Pre-compute examples in this codebase:**
- `preview()` line 149: `local spaces=$(printf "%*s" "$width" "")` — computed once, reused N times
- `_init_tui()` line 272: `line_fill=$(printf "%*s" "$MAX_WIDTH" "")` — computed once, reused in wall loop

## 7. Minimize cursor positioning

Each `\e[row;colH` is sent to the terminal and parsed. Embed positions inline rather than calling `_draw_at` repeatedly.

**Bad:** `_draw_at "$row"` + `printf "text"` per field

**Good:** Embed `\e[...H` directly in the batch string

## 8. Avoid `echo` in TUI code

`echo` adds a trailing newline and can't handle `\e` escapes portably. Always use `printf >&2`.

## 9. Check for hidden forks

These are easy to miss:
- `$(printf "%b" "$msg")` in `_draw_header()` line 457 — forks once per redraw
- `$(echo "$query" | _tolower)` — two forks inside form dropdown filter loop (lines 1259, 1264, 1335, etc.)
- `mktemp` in every `textbox`/`tailbox`/`preview` invocation — creates temp file + forks

## Bottleneck checklist

1. Count `$(...)` and backtick occurrences inside `while`/`for` render loops
2. Look for `printf >&2` inside loops — should be one `printf "%b"` at the end
3. Check for external tools (`sed`, `tr`, `cut`, `expr`) in rendering paths
4. Verify `_draw_footer`-style clearing loops aren't per-frame bottlenecks
5. Ensure `_draw_header` isn't called unnecessarily when only data changes (not layout)
