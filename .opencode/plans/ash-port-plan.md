# Ash Porting Plan: terminal-menus.sh

## Goal
Make `terminal-menus.sh`, `terminal-menus-demo.sh`, and `preview.sh` run under Busybox ash (#!/bin/ash).

## Strategy

### Pattern Matching
Replace `[[ ]]` with helper functions + `[ ]`:
- `_match "$var" "pattern*"` → returns 0 if pattern matches (replaces `[[ "$var" == pattern* ]]`)
- `_is_numeric "$var"` → returns 0 if string is all digits (replaces `[[ "$var" =~ ^[0-9]+$ ]]`)
- Simple tests (`-n`, `-z`, `-f`, `-eq`, `-lt`, etc.) → `[ ]` works as-is in ash

### Arrays → Newline-Delimited Strings
Small-to-medium lists stored as newline-separated strings in variables:
- `_arr_count "$var"` → echo count of lines
- `_arr_get "$var" $idx` → echo line at 1-based idx
- Iteration: `echo "$var" | while IFS= read -r item; do`

Boolean state per index (selected, toggled) → `eval "sel_${idx}=$value"`
Large datasets → temp files

### Mechanical Bashism Fixes
| Bashism | Replacement | Count |
|---|---|---|
| `[[ ]]` → `[ ]` / `_match` | helper + case | ~671 |
| `printf -v var "fmt"` | `var=$(printf "fmt")` | 29 |
| `<<< "$var"` | `echo "$var" \|` or heredoc | 21 |
| `local -i` | `local` | ~7 |
| Process subst `<()` | temp file | 2 |
| `shopt -s nocasematch` | `_match` or `tr` | ~20 |
| `${!var}` indirect | `eval "val=\"\$$varname\""` | ~6 |
| `${var,,}` lowercase | `$(echo "$var" \| tr '[:upper:]' '[:lower:]')` | 1 |
| `trap ... EXIT` | `trap ... 0` | 2 |
| `read -d` | `IFS=';' read -r` | 3 |

## Execution Order

### Phase 1: Foundation
1. Add helpers to `terminal-menus.sh` (after `_esc()`)
2. Fix shebang in `terminal-menus-demo.sh`

### Phase 2: Mechanical Changes (all files)
3. `trap EXIT` → `trap 0`
4. `local -i` → `local`
5. `printf -v` → cmd subst
6. `<<<` → pipes/heredocs
7. Process subst → temp files
8. `${!var}` → `eval`
9. `${var,,}` → `tr`
10. `read -d` → IFS
11. `shopt` → remove/emulate

### Phase 3: `[[ ]]` Conversion
12. `terminal-menus.sh` — all `[[ ]]` → `[ ]` or `_match`
13. `terminal-menus-demo.sh` — all `[[ ]]` → `[ ]` or `_match`
14. `preview.sh` — all `[[ ]]` → `[ ]` or `_match`

### Phase 4: Array Conversion
15. `terminal-menus.sh` — all arrays → newline-delimited strings + eval booleans
16. `terminal-menus-demo.sh` — all arrays → newline-delimited strings
17. `preview.sh` — any arrays → newline-delimited strings

### Phase 5: Verification
18. `ash -n terminal-menus.sh`
19. `ash -n terminal-menus-demo.sh`
20. `ash -n preview.sh`

## Helper Functions (to add)

```sh
# --- Portable helpers for ash compat ---
_match() { case $1 in $2) return 0;; esac; return 1; }
_is_numeric() { case $1 in ''|*[!0-9]*) return 1;; esac; return 0; }
_arr_count() { [ -z "$1" ] && echo 0 || printf "%s" "$1" | grep -c '^'; }
_arr_get() { printf "%s" "$1" | sed -n "${2}p"; }
```

## Key [[ → _match Conversions

```sh
Before                          After
──────────────────────────────────────────────────────────
[[ "$x" = "y" ]]               [ "$x" = "y" ]
[[ "$x" != "y" ]]              [ "$x" != "y" ]
[[ -n "$x" ]]                  [ -n "$x" ]
[[ -z "$x" ]]                  [ -z "$x" ]
[[ $x -gt $y ]]                [ $x -gt $y ]
[[ ! -f "$f" ]]                [ ! -f "$f" ]
[[ -n "$x" && -f "$y" ]]       [ -n "$x" ] && [ -f "$y" ]
[[ "$x" = "y"* ]]              _match "$x" "y*"
[[ "$x" = y* || "$x" = z* ]]   _match "$x" "y*" || _match "$x" "z*"
[[ "$x" =~ ^[0-9]+$ ]]        _is_numeric "$x"
[[ "$x" =~ ^([ab])$ ]]         _match "$x" "a" || _match "$x" "b"
[[ ! -z "$x" ]]                [ -n "$x" ]
```

## Key Array → String Conversions

### Simple list (menu options, file items)
```sh
# Before
local options=("$@")
for opt in "${options[@]}"; do
    echo "$opt"
done

# After
local options=""
for _opt in "$@"; do
    options="${options:+${options}
}${_opt}"
done
echo "$options" | while IFS= read -r opt; do
    [ -n "$opt" ] || continue
    echo "$opt"
done
```

### Boolean per-index (selected items, radio state)
```sh
# Before
local selected=()
selected[idx]=1
echo ${selected[i]}

# After
local __c=0
for __a in "$@"; do
    eval "sel_${__c}=0"
    __c=$((__c + 1))
done
eval "sel_${idx}=1"
eval "is_sel=\"\$sel_${i}\""
```

### Fixed-size init with loop
```sh
# Before
local selected=(); for ((i=0; i<count; i++)); do selected[i]=0; done

# After
for ((i=0; i<count; i++)); do eval "sel_${i}=0"; done
```

## Files to Modify

1. `/initrd/mnt/dev_save/sites/github/sc0ttj/terminal-menus.sh/terminal-menus.sh` (5092 lines)
2. `/initrd/mnt/dev_save/sites/github/sc0ttj/terminal-menus.sh/terminal-menus-demo.sh` (581 lines)
3. `/initrd/mnt/dev_save/sites/github/sc0ttj/terminal-menus.sh/preview.sh` (33 lines)
