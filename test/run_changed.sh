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

# 1. If terminal-menus.sh or terminal-menus-demo.sh changed, schedule test run
echo "$changed" | grep -qE "(terminal-menus\.sh|terminal-menus-demo\.sh)" && tests="test.test_demo_widgets"

# 2. If the test file itself changed, include it
echo "$changed" | grep -q "test_demo_widgets" && tests="test.test_demo_widgets"

# 3. If demo_wrapper.sh changed, schedule test run
echo "$changed" | grep -q "demo_wrapper\.sh" && tests="test.test_demo_widgets"

# If nothing matched, run full suite
[ -z "$tests" ] && tests="all"

if [ "$mode" = "list" ]; then
    if [ -z "$tests" ] || [ "$tests" = "all" ]; then
        echo "All tests (full suite)"
    else
        echo "$tests"
    fi
    exit 0
fi

if [ -z "$tests" ] || [ "$tests" = "all" ]; then
    echo "Running full demo test suite ..."
    python3 -m unittest test.test_demo_widgets -v
else
    echo "Running affected tests: $tests"
    # shellcheck disable=SC2086
    python3 -m unittest $tests -v
fi
