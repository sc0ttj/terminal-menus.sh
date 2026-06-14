#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
mkdir -p /tmp/tui_test_fm
echo "file1" > /tmp/tui_test_fm/file1.txt
echo "file2" > /tmp/tui_test_fm/file2.txt
mkdir -p /tmp/tui_test_fm/subdir
echo "subfile" > /tmp/tui_test_fm/subdir/sub.txt
filemanager "FM" "/tmp/tui_test_fm" 3
FM_EXIT=$?
echo "EXIT=$FM_EXIT"
echo "RESULT=$TUI_RESULT"
rm -rf /tmp/tui_test_fm
