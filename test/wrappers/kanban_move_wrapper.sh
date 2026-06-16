#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - kanban (move+sort)"
mkdir -p /tmp/tui_kanban_test/Kanban_Example
echo "Test note 1" > /tmp/tui_kanban_test/Kanban_Example/note1.md
echo "Test note 2" > /tmp/tui_kanban_test/Kanban_Example/note2.md
kanban "Kanban" "Move and sort test" /tmp/tui_kanban_test
echo "EXIT=$?"
echo "RESULT=dismissed"
rm -rf /tmp/tui_kanban_test
