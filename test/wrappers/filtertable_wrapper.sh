#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - filtertable"

cat > /tmp/tui_filter_demo.csv << 'EOF'
App,Version,Usage,Command
Update,2.4.1,System,echo "sudo apt update"
Clean,N/A,Disk,echo "rm -rf /tmp/*"
Logs,1.0,Monitor,tailbox "System" "/var/log/syslog"
MySQL,Stopped,3306,echo "MySQL is down"
Jenkins,Running,8080,echo "Build #42 passed"
Docker,24.0.5,Engine,echo "docker ps -a"
Nginx,1.24.0,Port 80,echo "nginx -t"
Redis,7.2,Cache,echo "redis-cli info"
Python,3.11.4,Runtime,echo "python3 --version"
NodeJS,20.5.0,Runtime,echo "node -v"
Git,2.41.0,SCM,echo "git status"
HTOP,3.2.2,Monitor,echo "htop"
SSH,OpenSSH,Port 22,echo "who"
PostgreSQL,15.3,DB,echo "pg_isready"
UFW,Active,Firewall,echo "ufw status"
Cron,Running,System,echo "crontab -l"
Grafana,10.0.3,Metrics,echo "systemctl status grafana"
VSCode,1.81.0,Editor,echo "code --version"
Wireshark,4.0.7,Network,echo "tshark -D"
SystemInfo,1.0,Utility,echo "uname -a"
EOF

RESULT_CMD=$(filtertable "Filterable table" "Type to search, pick an item." "/tmp/tui_filter_demo.csv" 3)
rm -f /tmp/tui_filter_demo.csv
echo "EXIT=$?"
echo "RESULT=$RESULT_CMD"