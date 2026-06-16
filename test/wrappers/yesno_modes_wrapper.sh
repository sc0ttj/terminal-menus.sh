#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - yesno (modes)"
export OK_LABEL="Show me!"

msgbox "MODES" "
 
You can customise the widget position and size with these different
\"modes\":
 
  centered, classic, fullscreen, popup,
  top, bottom, toast, palette, custom. 
 
You can also get different \"looks\" by enabling/disabling \$BACKTITLE.
 
You can also leave title (\$1) and msg (\$2) empty - the blank space
they leave will be automaitcally removed."

# Show first mode: centered
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - yesno (modes: fullscreen)"
export YES_LABEL="Yes"
export NO_LABEL="No"
yesno "Choose a mode" "Current mode: fullscreen.\nSee next mode?" 1
echo "EXIT=$?"
echo "RESULT=modes_demo"