#!/bin/sh
# test/test_shell_compat.sh - Shell compatibility test runner
# Verifies terminal-menus.sh and terminal-menus-demo.sh work under
# both ash (Busybox) and bash via syntax check + functional pty test.
#
# Usage: ./test/test_shell_compat.sh

cd "$(dirname "$0")/.." || exit 1

PASS=0
FAIL=0
RESULTS=""

pass() { PASS=$((PASS+1)); RESULTS="${RESULTS}  PASS: $1\n"; }
fail() { FAIL=$((FAIL+1)); RESULTS="${RESULTS}  FAIL: $1\n"; }

echo "=== Shell Compatibility Tests ==="
echo ""

# --- Syntax checks ---
echo "--- Syntax checks ---"
for shell in ash bash; do
    for script in terminal-menus.sh terminal-menus-demo.sh; do
        if $shell -n "$script" 2>/dev/null; then
            pass "syntax: $shell -n $script"
        else
            fail "syntax: $shell -n $script"
        fi
    done
done

echo ""
echo "--- Functional (pty) tests ---"
# Run form pty test under each shell
for shell in ash bash; do
    if SHELL="$shell" python3 test/test_form_pty.sh 2>&1; then
        pass "functional: SHELL=$shell test/test_form_pty.sh"
    else
        fail "functional: SHELL=$shell test/test_form_pty.sh"
    fi
done

echo ""
echo "--- Widget integration tests ---"
# Run all widget test modules via unittest
echo "  Widget tests..."
if python3 -m unittest discover -s test -p "test_widget_*.py" -v 2>&1; then
    pass "widget tests: python3 -m unittest discover"
else
    fail "widget tests: python3 -m unittest discover"
fi

echo ""
echo "=== Results ==="
printf "$RESULTS"
echo ""
echo "Passed: $PASS  Failed: $FAIL"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0