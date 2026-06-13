# Remaining Bug Fixes for terminal-menus.sh

## Fix 1 — Password prefix detection (line 1111)
**Change:** `>**` → `>\*`

```
_match "$line" ">\*" && prefix=">* "
```

**Why:** `**` in a case pattern is equivalent to `*` (matches anything). `>\*` matches a literal `>*` (password prefix) vs `>*` (input prefix).

---

## Fix 2 — Password label stripping in `_draw_form_field` (line 501)
**Change** Replace single `#>` strip with two-step fallback:

```
clean_lbl="${label#\>* }"; [ "$clean_lbl" = "$label" ] && clean_lbl="${label#> }"
```

**Why:** Password field labels are stored as `>* name`. `#> ` strips only `> ` leaving `* name`. First try `#\>* ` (strip `>* `), fall back to `#> ` (strip `> ` for input fields).

---

## Fix 3 — Password detection in `_draw_form_field` (line 512)
**Change:** `>*` → `>\*`

```
if _match "$label" ">\*"; then
```

**Why:** `>*` matches ALL fields starting with `>` (both `> name` and `>* name`). `>\*` matches only password fields starting with `>*`.

---

## Fix 4 — Navigation patterns (lines 1309, 1315, 1332)
**Change:** `[>*` → `>*` at all three lines.

```
_match "$cf" ">*" || _match "$cf" "[*" || _match "$cf" "(*" || _match "$cf" "{*" && break
```

**Why:** `[>*` is a bracket expression matching a single `>` or `*` character. `>*` is a glob matching any string starting with `>` (both `> name` input and `>* name` password).

---

## Fix 5 — Dropdown area management (after line 1242)
**Add** after the `done` of the `j=0; while ...` loop:

```
row=$((drow > row ? drow : row))
```

**Why:** After rendering OPEN dropdown items at row `drow`, the global `row` variable is not advanced past them. This causes subsequent fields and footer to overlap dropdown items. The `? :` ternary ensures `row` only moves forward.

---

## Fix 6 — `master_cmd` single-quote breakage (line 3155)
**Change** from:

```
eval "master_cmd_$master_cmd_count='$cmd'"
```

to:

```
_cmd_safe="$cmd"
eval "master_cmd_$master_cmd_count=\"\$_cmd_safe\""
```

**Why:** When `$cmd` contains single quotes (e.g., from CSV command column like `modal "inputbox 'Profile' 'Enter name:'"`), the `'…'` wrapper terminates early causing shell to execute fragments as commands. The temp variable approach avoids this by using double quotes and `$_cmd_safe` variable reference.
