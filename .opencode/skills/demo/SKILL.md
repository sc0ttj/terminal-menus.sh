---
name: demo
description: Run the full interactive demo that exercises every widget. Use when the user asks to run the demo, preview widgets, or do a smoke test of the TUI library.
---

# Demo

Run the full interactive demo script, which exercises every widget end-to-end.

## Run the demo

```bash
./terminal-menus-demo.sh
```

Keystroke drivers and automated visual tests are also available in `test/`:

- Full 23-widget automated demo: `test/test_full_demo.sh`
- Individual widget wrappers + drivers in `test/wrappers/` and `test/drivers/`
