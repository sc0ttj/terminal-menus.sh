---
name: test-widgets
description: Run the widget integration test suite (Python unittest). Use when the user asks to run tests, check test results, or run a specific widget test.
---

# Test Widgets

Run the widget integration tests across all 22 widgets.

## Run full test suite

```bash
cd test && python3 -m unittest test_demo_widgets -v
```

## Run under a specific shell

```bash
SHELL=bash cd test && python3 -m unittest test_demo_widgets -v
SHELL=ash  cd test && python3 -m unittest test_demo_widgets -v
```

## Run a single widget module

```bash
python3 -m unittest test.test_demo_widgets.TestMenu -v
```

## Run a single test case

```bash
python3 -m unittest test.test_demo_widgets.TestMenu.test_default -v
```

## Test framework

- `test/testlib.py` — `PtyRunner`, `TuiTestCase`, `KEY` constants
- `test/test_demo_widgets.py` — all 22 widgets, 92 tests
- No X server required (pty-based)
