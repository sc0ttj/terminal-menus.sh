---
name: test-widgets
description: Run the widget integration test suite (Python unittest). Use when the user asks to run tests, check test results, or run a specific widget test.
---

# Test Widgets

Run the 80+ widget integration tests across all 22 widget modules.

## Run full test suite

```bash
python3 -m unittest discover -s test -p "test_widget_*.py" -v
```

## Run under a specific shell

```bash
SHELL=bash python3 -m unittest discover -s test -p "test_widget_*.py" -v
SHELL=ash  python3 -m unittest discover -s test -p "test_widget_*.py" -v
```

## Run a single widget module

```bash
python3 -m unittest test.test_widget_menu -v
```

## Run a single test case

```bash
python3 -m unittest test.test_widget_menu.TestMenu.test_menu_navigation -v
```

## Test framework

- `test/testlib.py` — `PtyRunner`, `TuiTestCase`, `KEY` constants
- 22 test modules in `test/test_widget_*.py`
- No X server required (pty-based)
