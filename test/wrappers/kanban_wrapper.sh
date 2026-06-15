#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
mkdir -p ~/tui_test_project
echo "Todo,In Progress,Done" > ~/tui_test_project/.project-config

cat <<'TIX' > ~/tui_test_project/implement_search.md
title: Implement full-text search
status: Todo
rank: 30
created: 2026-06-10-09:00:00
modified: 2026-06-10-09:00:00
completed:
author: alice
owner: bob
tags: @project +frontend +search
---
Build a full-text search feature using an inverted index.
TIX

cat <<'TIX' > ~/tui_test_project/fix_auth_timeout.md
title: Fix auth token refresh timeout
status: In Progress
rank: 60
created: 2026-06-08-14:30:00
modified: 2026-06-14-11:15:00
completed:
author: bob
owner: alice
tags: @bug +backend +auth
---
The OAuth token refresh handler silently fails after 30s.
TIX

cat <<'TIX' > ~/tui_test_project/add_unit_tests.md
title: Add unit tests for API module
status: In Progress
rank: 50
created: 2026-06-05-10:00:00
modified: 2026-06-13-16:45:00
completed:
author: alice
owner: alice
tags: @test +api
---
Reach 80% coverage on the REST API endpoints.
TIX

cat <<'TIX' > ~/tui_test_project/setup_logging.md
title: Set up structured logging
status: Done
rank: 90
created: 2026-06-01-08:00:00
modified: 2026-06-12-12:00:00
completed: 2026-06-12-12:00:00
author: bob
owner: bob
tags: @ops +observability
---
Replaced plain syslog with JSON-structured logging via fluentd.
TIX

kanban "Kanban" "Test board" ~/tui_test_project
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"
rm -rf ~/tui_test_project
