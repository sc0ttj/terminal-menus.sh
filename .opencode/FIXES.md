# Fixes to apply

## 1. Fix bold text appearing to right and below current cursor position

Any cell in the spreadsheet widget which is below and/or to the right of the current cursor position is bold.
Fix it so that only the currently focused cell is bold text, all others normal text.

Look in the spreadsheet() function.

## 2. Fix file_manager cursor marker placement.

The white block that marks the current cursor position in the command prompts of the file_manage are one character too far to the right.

Fix it so that the cursor marker is placed in the correct position - one character to the right of the typed character (one character left of where it is currently).

## 3. Make sure the `tree` widget returns the whole path of the selected item, in the form "a/b/c", not only returning "c".

## 
