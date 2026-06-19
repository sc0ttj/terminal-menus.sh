#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
cleanup
mkdir -p /tmp/_test_kanban
echo "Backlog,In Progress,Done" > /tmp/_test_kanban/.project-config
NOW=$(date +"%Y-%m-%d-%H:%M:%S")
cat > /tmp/_test_kanban/task1.md <<MDEOF
title: Test task
status: Backlog
created: $NOW
modified: $NOW
completed:
rank: 10
author: test
owner: test
tags: @test
---
Test description
MDEOF
TUI_MODE=fullscreen kanban "Board" "Test" /tmp/_test_kanban
echo "EXIT=$?"
rm -rf /tmp/_test_kanban