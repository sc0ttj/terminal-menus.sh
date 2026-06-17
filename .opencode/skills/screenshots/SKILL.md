---
name: screenshots
description: Generate screenshots of TUI widgets. Use when the user wants to regenerate screenshots for the README, or fix/update a specific widget screenshot.
---

# Screenshots

Regenerate all 23 widget screenshots, or a single one, via the `generate_readme_screenshots.sh` script.

## Requirements

- `Xvfb`, `xterm`, `xdotool`, `ImageMagick` (`xwd` + `convert`), `fonts-dejavu-core`
- `ash`, `bash`
- `scrot` (optional, last-resort fallback)

## Regenerate all screenshots

```bash
rm -f screenshots/*.png
bash scripts/generate_readme_screenshots.sh
```

## Regenerate a single screenshot

Delete the specific PNG, then run the generator (it skips existing files):

```bash
rm -f screenshots/mainmenu.png
bash scripts/generate_readme_screenshots.sh
```

## Troubleshooting

- **Black text** → missing `$FG_TEXT_ESC` in a `printf` call
- **xwd capture fails** → run `xwininfo -tree`, increase sleep in `interactive_runner.sh:screenshot()`
- **White edges** → xterm `-bg '#222222'` missing; delete PNG and re-capture
- **Window not found** → `xdotool search --classname "xterm"` fallback in runner
