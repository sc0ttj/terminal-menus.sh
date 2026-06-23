---
name: shell-search
description: Search shell code using grep or ag (NOT ripgrep). Use whenever searching code patterns, finding function definitions, tracking variable usage, or identifying color escape issues in this shell codebase.
---

# Shell Search

**CRITICAL: This system has `grep` and `ag` (the Silver Searcher). It does NOT have `rg` (ripgrep). Never use `rg`.**

## Quick reference

| Goal | Command |
|---|---|
| Find function definition | `grep -rn '^func_name()' terminal-menus.sh` |
| Find all references | `grep -rn 'func_name' terminal-menus.sh` |
| Case-insensitive search | `grep -rni 'pattern' terminal-menus.sh` |
| Count matches | `grep -rc 'pattern' terminal-menus.sh` |
| Search with context | `grep -rn -B2 -A5 'pattern' terminal-menus.sh` |
| Search test files | `grep -rn 'pattern' test/` |
| Exclude screenshots | `grep -rn 'pattern' --exclude-dir=screenshots` |
| Search with ag (faster) | `ag 'pattern' terminal-menus.sh` |

## Common search patterns for this codebase

### Find where a variable is declared (local or assignment)
```bash
grep -rn 'local var_name\|^[[:space:]]*var_name=' terminal-menus.sh
```

### Find a widget function definition
```bash
grep -rn '^filepicker()' terminal-menus.sh
```

### Find all uses of a color variable
```bash
grep -rn 'HL_WHITE_BOLD' terminal-menus.sh
```

### Find printf calls missing a foreground color (common bug)
```bash
# Find BG_* escapes used without following FG_* escape on the same line:
grep -n 'BG_WID_ESC\|BG_MAIN_ESC\|BG_INPUT_ESC\|BG_BLUE_ESC' terminal-menus.sh | grep -v 'FG_TEXT_ESC\|FG_BLUE_BOLD\|FG_INPUT_ESC\|FG_'
```

### Find case statement key bindings
```bash
grep -n '".*")' terminal-menus.sh | head -50
```

### Find eval-based numbered variable patterns
```bash
grep -rn 'eval ".*_\$' terminal-menus.sh
```

### Search test files for specific assertions
```bash
grep -rn 'assertEqual\|assertIn\|assertTrue' test/test_widget_*.py
```

### Search for potential ash incompatibilities
```bash
grep -rn '\[\[.*==.*\*\]\]' terminal-menus.sh
grep -rn '=~' terminal-menus.sh
grep -rn '\[\[.*==.*\*' terminal-menus.sh
```

### Find read_key / case handler patterns
```bash
grep -n '_read_key\|case "\$key" in' terminal-menus.sh
```

## Filter results

```bash
# Just list file names matching
grep -rl 'pattern' terminal-menus.sh

# Invert match
grep -rn 'pattern' terminal-menus.sh | grep -v 'exclude_pattern'

# Line count only
grep -c 'pattern' terminal-menus.sh
```

## Using ag

```bash
# Faster recursive search (respects .gitignore)
ag 'pattern' terminal-menus.sh

# Search with file type filter
ag --shell 'pattern'
ag --python 'pattern'

# Context lines
ag -C 3 'pattern'
```
