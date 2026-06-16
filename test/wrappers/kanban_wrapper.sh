#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - kanban"

# Setup a project (same as demo)
mkdir -p ~/my_project
echo "Backlog,In Progress,Testing,Done" > ~/my_project/.project-config

NOW=$(date +"%Y-%m-%d-%H:%M:%S")

# Create realistic tickets (from demo)
cat <<EOF > ~/my_project/api_rate_limiting.md
title: Implement API rate limiting
status: Backlog
created: $NOW
modified: $NOW
completed:
rank: 10
author: $(whoami)
owner: $(whoami)
tags: @feature +backend +security
---
Add token-bucket rate limiting to all public API endpoints.
EOF

cat <<EOF > ~/my_project/login_oauth.md
title: Add OAuth2 login support
status: In Progress
created: $(date -d "3 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
modified: $NOW
completed:
rank: 40
author: $(whoami)
owner: $(whoami)
tags: @feature +auth +frontend
---
Integrate Google and GitHub OAuth2 providers. Wire up the callback flow and JWT session tokens.
EOF

cat <<EOF > ~/my_project/ci_pipeline.md
title: Set up CI/CD pipeline
status: In Progress
created: $(date -d "5 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
modified: $NOW
completed:
rank: 50
author: $(whoami)
owner: $(whoami)
tags: @ops +infra
---
Configure GitHub Actions for lint, test, build, and deploy to staging.
EOF

cat <<EOF > ~/my_project/search_index_fix.md
title: Fix search index corruption bug
status: Testing
created: $(date -d "7 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
modified: $(date -d "1 day ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
completed:
rank: 80
author: $(whoami)
owner: $(whoami)
tags: @bug +search +backend
---
Rare race condition corrupts the inverted index under concurrent writes. Fix applied, needs QA sign-off.
EOF

cat <<EOF > ~/my_project/db_migration.md
title: Migrate database to PostgreSQL
status: Done
created: $(date -d "14 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
modified: $(date -d "2 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
completed: $(date -d "2 days ago" +"%Y-%m-%d-%H:%M:%S" 2>/dev/null || echo "$NOW")
rank: 95
author: $(whoami)
owner: $(whoami)
tags: @ops +database
---
Migrated from SQLite to PostgreSQL 16 with zero-downtime replication. All data verified.
EOF

cat <<EOF > ~/my_project/readme_update.md
title: Update project README
status: Backlog
created: $NOW
modified: $NOW
completed:
rank: 20
author: $(whoami)
owner: $(whoami)
tags: @docs +meta
---
Document the new API endpoints, setup instructions, and contribution guide.
EOF

# Launch the manager
TUI_MODE=fullscreen kanban "Project" "Manage your tickets and notes" ~/my_project
echo "EXIT=$?"
echo "RESULT=$TUI_RESULT"

# Cleanup
rm -rf ~/my_project