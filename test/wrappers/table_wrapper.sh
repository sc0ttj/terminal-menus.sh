#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - table"

cat > /tmp/tui_table_demo.csv << 'EOF'
App,Version,Usage,Command
Update,2.4.1,System,echo "sudo apt update"
Clean,N/A,Disk,echo "rm -rf /tmp/*"
Logs,1.0,Monitor,tailbox "System" "/var/log/syslog"
MySQL,Stopped,3306,echo "MySQL is down"
Jenkins,Running,8080,echo "Build #42 passed"
Docker,24.0,Engine,echo "docker ps -a"
Nginx,1.24,Web,echo "nginx -t"
Redis,7.2,Cache,echo "redis-cli info"
Python,3.11,Lang,echo "python3 --version"
NodeJS,20.5,JS,echo "node -v"
Git,2.41,SCM,echo "git status"
HTOP,3.2.2,Monitor,echo "htop"
SSH,Active,Port 22,echo "who"
Postgres,15.3,DB,echo "pg_isready"
UFW,Active,FW,echo "ufw status"
Cron,Running,System,echo "crontab -l"
Grafana,10.0,Metrics,echo "systemctl status"
VSCode,1.81,Editor,echo "code --version"
TShark,4.0.7,Net,echo "tshark -D"
System,1.0,Utility,echo "uname -a"
EOF

LAUNCH_CMD=$(table "Table" "Pick an item" "/tmp/tui_table_demo.csv" 3)
rm -f /tmp/tui_table_demo.csv
echo "EXIT=$?"
echo "RESULT=$LAUNCH_CMD"