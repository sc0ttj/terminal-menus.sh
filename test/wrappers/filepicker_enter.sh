#!/bin/ash
cd "$(dirname "$0")/../.."
. ./terminal-menus.sh
mkdir -p /tmp/_test_fp
touch /tmp/_test_fp/file1 /tmp/_test_fp/file2
RESULT=$(filepicker "Pick" "Choose a file" "/tmp/_test_fp" 1)
echo "EXIT=$?"
echo "RESULT=$RESULT"
rm -rf /tmp/_test_fp