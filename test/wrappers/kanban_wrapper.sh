#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
mkdir -p ~/tui_test_project
echo "Todo,In Progress,Done" > ~/tui_test_project/.project-config
mkdir -p ~/tui_test_project/tickets
cat <<'TIX' > ~/tui_test_project/tickets/task1.md
title: Task 1
status: Todo
rank: 100
---
Do the thing
TIX
kanban "Kanban" "Test board" ~/tui_test_project
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
rm -rf ~/tui_test_project
