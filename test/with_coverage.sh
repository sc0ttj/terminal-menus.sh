#!/bin/ash
# Run the widget test suite under coverage.py and generate a report.
# Usage:
#   ./test/with_coverage.sh          # run + report
#   ./test/with_coverage.sh --html   # also generate HTML report
cd "$(dirname "$0")/.."

# Try to install coverage for the active Python if missing
python3 -c "import coverage" 2>/dev/null || {
    echo "coverage.py not found; attempting install ..." >&2
    pip install coverage 2>/dev/null && echo "installed" >&2
    # If that failed, try pip3 for Python 3
    python3 -m pip install coverage 2>/dev/null && echo "installed" >&2
}
python3 -c "import coverage" 2>/dev/null || {
    echo "ERROR: coverage.py is not installed. Install it with:" >&2
    echo "  pip install coverage" >&2
    exit 1
}

# Clean previous coverage data
rm -f .coverage

echo "Running test suite under coverage ..."
python3 -m coverage run -m unittest discover -s test -p "test_demo_widgets*" || true

echo ""
echo "=== Coverage Report ==="
python3 -m coverage report -m

if [ "$1" = "--html" ]; then
    python3 -m coverage html -d coverage_html
    echo "HTML report written to coverage_html/index.html"
fi
