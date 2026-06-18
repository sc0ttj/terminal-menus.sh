#!/bin/ash
# Run tests relevant to files changed in the working tree.
# Usage:
#   ./test/run_changed.sh            # run affected tests
#   ./test/run_changed.sh --list     # only list affected test files
#   ./test/run_changed.sh --diff     # show the git diff being checked
cd "$(dirname "$0")/.."

mode="run"
for arg in "$@"; do
    case "$arg" in
        --list) mode="list" ;;
        --diff) git diff --name-only HEAD; exit 0 ;;
    esac
done

# Gather changed files
changed=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only)
[ -z "$changed" ] && changed=$(git status --porcelain 2>/dev/null | awk '{print $2}')
[ -z "$changed" ] && { echo "No changes detected."; exit 0; }

tests=""

# 1. If a wrapper file changed, test its widget
for f in $changed; do
    case "$f" in
        test/wrappers/*_wrapper.sh)
            widget=$(echo "$f" | sed 's|test/wrappers/\(.*\)_wrapper\.sh|test_widget_\1|')
            tests="$tests test.${widget}"
            ;;
    esac
done

# 2. If a test file changed, include it
for f in $changed; do
    case "$f" in
        test/test_widget_*.py)
            mod=$(basename "$f" .py)
            tests="$tests test.${mod}"
            ;;
    esac
done

# 3. If terminal-menus.sh changed, check which widget functions were modified
echo "$changed" | grep -q "terminal-menus.sh" && {
    # Get function names added/modified in the diff
    touched=$(git diff HEAD -- terminal-menus.sh 2>/dev/null | grep '^[+-][a-z_]\+()' | sed 's/^[+-]//; s/()//' | sort -u)

    # Generic helpers touch everything
    for fn in $touched; do
        case "$fn" in
            _init_tui|_apply_layout|_draw_*|_init_*|_read_*|_cursor_*|_render_*|cleanup|handle_resize)
                # These affect ALL widgets — run the full suite
                tests="all"
                break 2
                ;;
        esac
    done

    # If flagged "all", we already broke out
    if [ "$tests" != "all" ]; then
        for fn in $touched; do
            case "$fn" in
                msgbox|infobox|yesno)        tests="$tests test.test_widget_msgbox test.test_widget_infobox test.test_widget_yesno" ;;
                inputbox|passwordbox|_input_core)  tests="$tests test.test_widget_inputbox test.test_widget_passwordbox" ;;
                menu|checklist|radiolist|_draw_list)  tests="$tests test.test_widget_menu test.test_widget_checklist test.test_widget_radiolist" ;;
                filtermenu)                   tests="$tests test.test_widget_filtermenu" ;;
                gauge)                        tests="$tests test.test_widget_gauge" ;;
                textbox|tailbox)              tests="$tests test.test_widget_textbox test.test_widget_tailbox" ;;
                tree*|configtree*|_tree_*)    tests="$tests test.test_widget_tree test.test_widget_configtree" ;;
                form|_filter_opts|_draw_form_field)  tests="$tests test.test_widget_form" ;;
                filepicker*)                  tests="$tests test.test_widget_filepicker" ;;
                filemanager*)                 tests="$tests test.test_widget_filemanager" ;;
                table|filtertable)            tests="$tests test.test_widget_table test.test_widget_filtertable" ;;
                spreadsheet)                  tests="$tests test.test_widget_spreadsheet" ;;
                kanban)                       tests="$tests test.test_widget_kanban" ;;
                mainmenu)                     tests="$tests test.test_widget_mainmenu" ;;
                modal|_handle_extra_keys|_parse_extra_keys)  tests="$tests test.test_widget_modal" ;;
            esac
        done
    fi

    [ -z "$tests" ] && tests="all"
}

# If nothing matched, run full suite
[ -z "$tests" ] && tests="all"

# Remove duplicates (skip if "all" to avoid turning empty into space)
if [ "$tests" != "all" ]; then
    tests=$(echo "$tests" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    [ "$tests" = " " ] && tests=""
fi
[ "$tests" = "all" ] && tests=""

if [ "$mode" = "list" ]; then
    if [ -z "$tests" ]; then
        echo "All tests (full suite)"
    else
        for t in $tests; do echo "$t"; done
    fi
    exit 0
fi

if [ -z "$tests" ]; then
    echo "Running full test suite (changes affect core infrastructure) ..."
    python3 -m unittest discover -s test -p "test_widget_*.py" -v
else
    echo "Running affected tests: $tests"
    # shellcheck disable=SC2086
    python3 -m unittest $tests -v
fi
