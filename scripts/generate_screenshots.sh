#!/bin/bash
# scripts/generate_screenshots.sh - Generate screenshots for all widgets
# Usage: bash scripts/generate_screenshots.sh
# Requires: Xvfb, xterm, xdotool, scrot, ash

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCREENSHOT_DIR="$PROJECT_ROOT/screenshots"
WRAPPER_DIR="$PROJECT_ROOT/test/wrappers"
DRIVER_DIR="$PROJECT_ROOT/test/drivers"
TMP_DIR="/tmp/tui_gen_$$"

mkdir -p "$SCREENSHOT_DIR" "$TMP_DIR"

RESULTS=()

# Kill any leftover Xvfb from previous aborted runs
pkill -f "Xvfb.*:$DISPLAY_NUM" 2>/dev/null || true

generate_one() {
    local name="$1"
    local wrapper="$2"
    local driver="$3"

    if [ -f "$SCREENSHOT_DIR/${name}.png" ]; then
        echo "SKIP $name (already exists)"
        RESULTS+=("SKIP  $name")
        return 0
    fi

    echo ""
    echo "============================================"
    echo "  Generating: $name"
    echo "============================================"

    local display_num=$((99 + RANDOM % 100))

    # Kill any leftover Xvfb on this display from a previous crash
    pkill -f "Xvfb.*:$display_num" 2>/dev/null || true

    local output
    output=$(DISPLAY_NUM=$display_num ash "$PROJECT_ROOT/test/interactive_runner.sh" "$wrapper" "$driver" 2>&1) || true

    local ss_path
    ss_path=$(echo "$output" | grep '\[SS\]' | head -1 | sed 's/^.*\[SS\] //')

    if [ -n "$ss_path" ] && [ -f "$ss_path" ]; then
        cp "$ss_path" "$SCREENSHOT_DIR/${name}.png"
        echo "  -> $SCREENSHOT_DIR/${name}.png"
        RESULTS+=("OK     $name")
    else
        echo "  WARNING: No screenshot captured for $name"
        echo "  Output:"
        echo "$output" | tail -5
        RESULTS+=("FAIL   $name")
    fi

    # Small gap between runs to ensure cleanup
    sleep 1
}

# ---- Generate temporary wrappers for widgets needing special env or timing ----
echo "Creating temporary wrappers..."

cat > "$TMP_DIR/infobox_wrapper.sh" << WRAP
#!/bin/ash
cd "$PROJECT_ROOT"
. ./terminal-menus.sh
infobox "Info" "Non-blocking info message"
sleep 3
echo "EXIT=\$?"
echo "RESULT=displayed"
WRAP

cat > "$TMP_DIR/gauge_wrapper.sh" << WRAP
#!/bin/ash
cd "$PROJECT_ROOT"
. ./terminal-menus.sh
( echo 10; sleep 1; echo 50; sleep 1; echo 90; sleep 1; echo 100 ) | gauge "Progress" "Loading..."
echo "EXIT=\$?"
echo "RESULT=complete"
WRAP

cat > "$TMP_DIR/spreadsheet_wrapper.sh" << WRAP
#!/bin/ash
cd "$PROJECT_ROOT"
. ./terminal-menus.sh
echo 'Category,Amount' > /tmp/tui_gen_ss_budget.csv
echo 'Food,100' >> /tmp/tui_gen_ss_budget.csv
echo 'Rent,500' >> /tmp/tui_gen_ss_budget.csv
TUI_MODE=fullscreen spreadsheet "Budget" "/tmp/tui_gen_ss_budget.csv"
echo "EXIT=\$?"
echo "RESULT=\$RESULT"
rm -f /tmp/tui_gen_ss_budget.csv
WRAP

cat > "$TMP_DIR/kanban_wrapper.sh" << WRAP
#!/bin/ash
cd "$PROJECT_ROOT"
. ./terminal-menus.sh
mkdir -p /tmp/tui_gen_ss_project
echo "Todo,In Progress,Done" > /tmp/tui_gen_ss_project/.project-config

cat <<'TIX' > /tmp/tui_gen_ss_project/implement_search.md
title: Implement full-text search
status: Todo
rank: 30
created: 2026-06-10-09:00:00
modified: 2026-06-10-09:00:00
completed:
author: alice
owner: bob
tags: @project +frontend +search
---
Build a full-text search feature using an inverted index.
TIX

cat <<'TIX' > /tmp/tui_gen_ss_project/fix_auth_timeout.md
title: Fix auth token refresh timeout
status: In Progress
rank: 60
created: 2026-06-08-14:30:00
modified: 2026-06-14-11:15:00
completed:
author: bob
owner: alice
tags: @bug +backend +auth
---
The OAuth token refresh handler silently fails after 30s.
TIX

cat <<'TIX' > /tmp/tui_gen_ss_project/add_unit_tests.md
title: Add unit tests for API module
status: In Progress
rank: 50
created: 2026-06-05-10:00:00
modified: 2026-06-13-16:45:00
completed:
author: alice
owner: alice
tags: @test +api
---
Reach 80% coverage on the REST API endpoints.
TIX

cat <<'TIX' > /tmp/tui_gen_ss_project/setup_logging.md
title: Set up structured logging
status: Done
rank: 90
created: 2026-06-01-08:00:00
modified: 2026-06-12-12:00:00
completed: 2026-06-12-12:00:00
author: bob
owner: bob
tags: @ops +observability
---
Replaced plain syslog with JSON-structured logging via fluentd.
TIX

TUI_MODE=fullscreen kanban "Kanban" "Test board" /tmp/tui_gen_ss_project
echo "EXIT=\$?"
echo "RESULT=\$TUI_RESULT"
rm -rf /tmp/tui_gen_ss_project
WRAP

chmod +x "$TMP_DIR"/*.sh

# ---- Generate screenshots ----

generate_one "msgbox"       "$WRAPPER_DIR/msgbox_wrapper.sh"       "$DRIVER_DIR/msgbox.driver"
generate_one "infobox"      "$TMP_DIR/infobox_wrapper.sh"           "$DRIVER_DIR/infobox.driver"
generate_one "yesno"        "$WRAPPER_DIR/yesno_wrapper.sh"        "$DRIVER_DIR/yesno.driver"
generate_one "inputbox"     "$WRAPPER_DIR/inputbox_wrapper.sh"     "$DRIVER_DIR/inputbox.driver"
generate_one "passwordbox"  "$WRAPPER_DIR/passwordbox_wrapper.sh"  "$DRIVER_DIR/passwordbox.driver"
generate_one "menu"         "$WRAPPER_DIR/menu_wrapper.sh"         "$DRIVER_DIR/menu.driver"
generate_one "checklist"    "$WRAPPER_DIR/checklist_wrapper.sh"    "$DRIVER_DIR/checklist.driver"
generate_one "radiolist"    "$WRAPPER_DIR/radiolist_wrapper.sh"    "$DRIVER_DIR/radiolist.driver"
generate_one "filtermenu"   "$WRAPPER_DIR/filtermenu_wrapper.sh"   "$DRIVER_DIR/filtermenu.driver"
generate_one "gauge"        "$TMP_DIR/gauge_wrapper.sh"             "$DRIVER_DIR/gauge.driver"
generate_one "textbox"      "$WRAPPER_DIR/textbox_wrapper.sh"      "$DRIVER_DIR/textbox.driver"
generate_one "tailbox"      "$WRAPPER_DIR/tailbox_wrapper.sh"      "$DRIVER_DIR/tailbox.driver"
generate_one "tree"         "$WRAPPER_DIR/tree_wrapper.sh"         "$DRIVER_DIR/tree.driver"
generate_one "configtree"   "$WRAPPER_DIR/configtree_wrapper.sh"   "$DRIVER_DIR/configtree.driver"
generate_one "form"         "$WRAPPER_DIR/form_wrapper.sh"         "$DRIVER_DIR/form.driver"
generate_one "filepicker"   "$WRAPPER_DIR/filepicker_wrapper.sh"   "$DRIVER_DIR/filepicker.driver"
generate_one "table"        "$WRAPPER_DIR/table_wrapper.sh"        "$DRIVER_DIR/table.driver"
generate_one "filtertable"  "$WRAPPER_DIR/filtertable_wrapper.sh"  "$DRIVER_DIR/filtertable.driver"
generate_one "spreadsheet"  "$TMP_DIR/spreadsheet_wrapper.sh"      "$DRIVER_DIR/spreadsheet.driver"
generate_one "kanban"       "$TMP_DIR/kanban_wrapper.sh"           "$DRIVER_DIR/kanban.driver"

# ---- Cleanup ----
rm -rf "$TMP_DIR"

# ---- Summary ----
echo ""
echo "============================================"
echo "  Results"
echo "============================================"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
echo "Screenshots in: $SCREENSHOT_DIR"
echo "Done."
