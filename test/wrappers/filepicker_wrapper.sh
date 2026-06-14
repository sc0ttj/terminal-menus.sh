#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
mkdir -p /tmp/tui_test_picker
echo "test content" > /tmp/tui_test_picker/file_a.txt
echo "more data" > /tmp/tui_test_picker/file_b.txt
RESULT=$(filepicker "Picker" "Choose a file:" "/tmp/tui_test_picker" 2)
echo "EXIT=$?"
echo "RESULT=$RESULT"
rm -rf /tmp/tui_test_picker
