#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - tailbox"

# Create a test log file if the system log doesn't exist or is empty
TEST_LOG="/tmp/tui_tailbox_test.log"
cat > "$TEST_LOG" << 'EOF'
2026-06-15 10:00:01 systemd[1]: Started Daily apt download activities.
2026-06-15 10:00:02 systemd[1]: Starting Daily apt upgrade and clean...
2026-06-15 10:00:03 apt-daily-upgrade[1234]: Reading package lists...
2026-06-15 10:00:04 apt-daily-upgrade[1234]: Building dependency tree...
2026-06-15 10:00:05 apt-daily-upgrade[1234]: 5 packages can be upgraded.
2026-06-15 10:00:06 systemd[1]: Started User Manager for UID 1000.
2026-06-15 10:00:07 systemd[1]: Starting Session 1 of user testuser.
2026-06-15 10:00:08 kernel: [12345.67] eth0: link up, 1Gbps
2026-06-15 10:00:09 sshd[5678]: Accepted password for testuser from 192.168.1.100
2026-06-15 10:00:10 systemd[1]: Started Docker Application Container Engine.
EOF

tailbox "" "Monitoring file: $TEST_LOG" "$TEST_LOG"
rm -f "$TEST_LOG"
echo "EXIT=$?"
echo "RESULT=closed"