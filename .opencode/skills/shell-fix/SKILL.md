---
name: shell-fix
description: Fix common shell code bugs in this TUI codebase. Use when fixing BusyBox ash incompatibilities, color rendering black-text bugs, missing local variables, broken case handlers, or preview_offset issues.
---

# Shell Fix Patterns

Common bugs in this codebase and their fixes.

## 1. BusyBox Ash: `[[` used where `case` is required

**Wrong:**
```bash
[[ "$var" == "prefix"* ]] && do_thing
[[ "$var" == *"sub"* ]] && do_thing
[[ "$var" =~ regex ]] && do_thing
```

**Fix:**
```bash
case "$var" in "prefix"*) do_thing ;; esac
case "$var" in *"sub"*) do_thing ;; esac
case "$var" in *"regex"*) do_thing ;; esac
```

**Always use `case`** for glob/pattern matching. `[[ == literal ]]` and `[[ -z/-n/-d/-f ]]` are fine.

## 2. Missing `local` declaration (pollutes global scope)

**Wrong:**
```bash
filepicker() {
    cur=${3:-0}
    preview_offset=0   # OOPS: sets global preview_offset
}
```

**Fix:** Always declare with `local`:
```bash
filepicker() {
    local cur=${3:-0}
    local preview_offset=0
}
```

**Check:** `grep -n '^[[:space:]]*[a-z_][a-z_]*=' terminal-menus.sh | grep -v '^[[:space:]]*local '`

## 3. Color rendering: background escape without foreground

**Wrong:**
```bash
printf "${BG_WID_ESC} text ${RESET}" >&2
# text appears BLACK on xterm with default black foreground
```

**Fix:** Always pair BG with FG:
```bash
printf "${BG_WID_ESC}${FG_TEXT_ESC} text ${RESET}${BG_MAIN_ESC}" >&2
```

**Safe pattern:** `"${BG_XYZ_ESC}${FG_TEXT_ESC} content ${RESET}${BG_MAIN_ESC}"`

## 4. Preview offset not initialized or not triggering redraw

**Wrong (preview scroll doesn't work):**
```bash
# In key handler:
"[" ) preview_offset=$((preview_offset - height)) ;;
# But preview_offset was never set to 0, and no last_cur update
```

**Fix:**
```bash
# In variable declarations:
local preview_offset=0

# In key handler:
"[") preview_offset=$((preview_offset - height)); [ $preview_offset -lt 0 ] && preview_offset=0; last_cur=-3 ;;
"]") preview_offset=$((preview_offset + height)); last_cur=-3 ;;
```

The `last_cur=-3` forces the preview redraw check (`if [ "$cur" -ne "$last_cur" ]`) to trigger.

## 5. _read_key: unhandled escape sequences

**Wrong:**
```bash
_read_key key
case "$key" in
    $'\033')
        _read_str_timeout 2 key
        case "$key" in
            "[A") do_up ;;
        esac ;;
esac
# Falls through if escape sequence is incomplete or different terminal
```

**Better (use `_read_key_esc` helper where available):**
```bash
_read_key_esc  # sets KEY and ESC_SEQ globals
case "$KEY" in
    "up") do_up ;;
    "down") do_down ;;
esac
```

## 6. Extraneous temp variables in arithmetic

**Wrong:**
```bash
"[") local pu_off=$((preview_offset - height)); [ $pu_off -lt 0 ] && pu_off=0; preview_offset=$pu_off ;;
```

**Fix:**
```bash
"[") preview_offset=$((preview_offset - height)); [ $preview_offset -lt 0 ] && preview_offset=0 ;;
```

## 7. Using `echo` instead of `printf >&2` for TUI

**Wrong:** `echo "text"` — goes to stdout (widget return channel), not terminal.

**Fix:** `printf "text" >&2`

## 8. Using external tools when built-ins suffice

| Wrong (slow, forks) | Fix (pure bash) |
|---|---|
| `sed 's/foo/bar/g' <<< "$var"` | `"${var//foo/bar}"` |
| `echo "$var" \| cut -d. -f1` | `"${var%.*}"` |
| `basename "$path"` | `"${path##*/}"` |
| `dirname "$path"` | `"${path%/*}"` |
| `expr $a + $b` | `$((a + b))` |
| `cat file \| while read` | `while read -r line; do ... done < file` |
| `tr 'A-Z' 'a-z'` | `"${var,,}"` (bash4+) or pipe to `_tolower` helper |

## 9. Arrays used instead of eval-based numbered vars

**Wrong:** `items=("a" "b" "c"); echo "${items[1]}"`

**Fix:**
```bash
items_count=3
eval "items_0='a'"
eval "items_1='b'"
eval "items_2='c'"
i=1; eval "echo \"\$items_$i\""
```

Use `while`/`for` loops with `eval` to iterate.

## 10. `read` without `-r` (backslash escaping issues)

**Wrong:** `read line` — backslashes in input are treated as escape chars.

**Fix:** Always use `read -r line` (except when reading keypresses with `_read_key`).
