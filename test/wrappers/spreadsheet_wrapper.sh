#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
export TUI_MODE=fullscreen
export BACKTITLE="terminal-menus.sh - spreadsheet"

# Create a sample financial sheet
cat > /tmp/tui_budget.csv << 'EOF'
Category,Amount,Notes
Groceries,150.00,Weekly shop
Rent,1200.00,Monthly
Internet,60.00,Fiber
Savings,200.00,Auto-transfer
Misc,45.50,Buffer
EOF

# Launch the spreadsheet widget
FINAL_DATA=$(spreadsheet "Spreadsheet editor" "/tmp/tui_budget.csv")

# Capture the exit status
if [ $? -eq 0 ]; then
    SUMMARY=$(echo "$FINAL_DATA" | head -n 8)
    echo "EXIT=0"
    echo "RESULT=$SUMMARY"
else
    echo "EXIT=1"
    echo "RESULT=discarded"
fi

rm -f /tmp/tui_budget.csv