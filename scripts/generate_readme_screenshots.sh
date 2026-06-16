#!/bin/bash
# scripts/generate_readme_screenshots.sh - Generate screenshots for all widgets for README
# Usage: bash scripts/generate_readme_screenshots.sh
# Requires: Xvfb, xterm, xdotool, scrot, ash, fonts-dejavu-core

# Don't use set -e to allow debugging
set +e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCREENSHOT_DIR="$PROJECT_ROOT/screenshots"
WRAPPER_DIR="$PROJECT_ROOT/test/wrappers"
DRIVER_DIR="$PROJECT_ROOT/test/drivers"
RUNNER="$PROJECT_ROOT/test/interactive_runner.sh"

mkdir -p "$SCREENSHOT_DIR"

# Terminal configuration
export TERMINAL_CMD="xterm -bw 0 -bg '#222222' -fa 'DejaVu Sans Mono' -fs 12 -geometry 100x30"
export TERM_GEOMETRY="100x30"

# Widget list in demo order (23 widgets + yesno variations = 24)
# Each entry: "widget_name" "wrapper_name" "driver_name"
WIDGETS=(
    "infobox infobox infobox"
    "msgbox msgbox msgbox"
    "yesno_modes yesno_modes yesno_modes"
    "yesno_theme yesno_theme yesno_theme"
    "inputbox inputbox inputbox"
    "passwordbox passwordbox passwordbox"
    "menu menu menu"
    "checklist checklist checklist"
    "radiolist radiolist radiolist"
    "filtermenu filtermenu filtermenu"
    "gauge gauge gauge"
    "textbox textbox textbox"
    "tailbox tailbox tailbox"
    "tree tree tree"
    "configtree configtree configtree"
    "form form form"
    "filepicker filepicker filepicker"
    "table table table"
    "filtertable filtertable filtertable"
    "filemanager filemanager filemanager"
    "spreadsheet spreadsheet spreadsheet"
    "kanban kanban kanban"
    "mainmenu mainmenu mainmenu"
)

RESULTS=()

echo "============================================"
echo "  Generating README Screenshots (23 widgets)"
echo "============================================"
echo "Terminal: $TERMINAL_CMD"
echo "Geometry: $TERM_GEOMETRY"
echo "Output: $SCREENSHOT_DIR"
echo ""

for entry in "${WIDGETS[@]}"; do
    read -r name wrapper driver <<< "$entry"

    if [ -f "$SCREENSHOT_DIR/${name}.png" ]; then
        echo "SKIP $name (already exists)"
        RESULTS+=("SKIP  $name")
        continue
    fi

    echo ""
    echo "============================================"
    echo "  Generating: $name"
    echo "============================================"

    # Use random display number to avoid conflicts
    display_num=$((99 + RANDOM % 100))

    # Kill any leftover Xvfb on this display
    pkill -f "Xvfb.*:$display_num" 2>/dev/null || true

    # Run the interactive runner - use temp file to avoid command substitution issues
    echo "  Running interactive_runner with DISPLAY_NUM=$display_num..."
    tmp_output="/tmp/tui_gen_output_$$.txt"
    DISPLAY_NUM=$display_num ash "$RUNNER" "$WRAPPER_DIR/${wrapper}_wrapper.sh" "$DRIVER_DIR/${driver}.driver" > "$tmp_output" 2>&1 || true
    ret=$?
    output=$(cat "$tmp_output")
    rm -f "$tmp_output"
    echo "  interactive_runner returned: $ret"
    echo "  Output length: ${#output}"

    # Extract screenshot path from output
    ss_path=$(echo "$output" | grep '\[SS\]' | head -1 | sed 's/^.*\[SS\] //')

    if [ -n "$ss_path" ] && [ -f "$ss_path" ]; then
        cp "$ss_path" "$SCREENSHOT_DIR/${name}.png"
        echo "  -> $SCREENSHOT_DIR/${name}.png"
        RESULTS+=("OK     $name")
    else
        echo "  WARNING: No screenshot captured for $name"
        echo "  Output (last 10 lines):"
        echo "$output" | tail -10
        RESULTS+=("FAIL   $name")
    fi

    # Small gap between runs to ensure cleanup
    sleep 1
done

# Summary
echo ""
echo "============================================"
echo "  Results"
echo "============================================"
for r in "${RESULTS[@]}"; do
    echo "$r"
done
echo ""
echo "Screenshots in: $SCREENSHOT_DIR"
echo "Done."