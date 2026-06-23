# test/test_full_demo.sh - Driver for full 23-widget demo
# Source'd by interactive_runner.sh - uses its helper functions
# Usage: ./test/interactive_runner.sh ../terminal-menus-demo.sh test/test_full_demo.sh

echo "=== Full Demo Test ==="

# 1. infobox: auto-dismiss (sleep 2 in demo), no key needed
wait_s 2.5
screenshot "01_infobox"

# 2. msgbox "A widget with two buttons"
wait_s 0.5
enter
screenshot "02_msgbox"

# 3. msgbox "MODES"
wait_s 0.5
enter
screenshot "03_modes_info"

# 4. Mode loop: 8 yesno dialogs + final msgbox
for i in 1 2 3 4 5 6 7 8; do
    wait_s 0.5
    enter
done
# Final "Thats all the modes" msgbox
wait_s 0.5
enter
screenshot "04_done_modes"

# 5. yesno "Theming demo" (default focus on NO, Enter = skip theme change)
wait_s 0.5
enter

# 6. inputbox "Username:" (default: "foo")
wait_s 0.5
enter
screenshot "05_inputbox"

# 7. passwordbox (default: "ppp")
wait_s 0.5
enter
screenshot "06_passwordbox"

# 8. menu "Pick a fruit:" (default: Banana)
wait_s 0.5
enter
screenshot "07_menu"

# 9. msgbox "You chose: Banana"
wait_s 0.5
enter

# 10. checklist "Select multiple:" (default: Option 2 checked)
wait_s 0.5
enter
screenshot "08_checklist"

# 11. msgbox "You chose: Option 2"
wait_s 0.5
enter

# 12. radiolist "Choose exactly one:" (default: Medium)
wait_s 0.5
enter
screenshot "09_radiolist"

# 13. msgbox "You chose: Medium"
wait_s 0.5
enter

# 14. filtermenu "Type to filter countries" (default: Australia at index 2)
wait_s 0.5
enter
screenshot "10_filtermenu"

# 15. msgbox "You chose: Australia"
wait_s 0.5
enter

# 16. gauge (auto via pipe, no key needed)
wait_s 3.0
screenshot "11_gauge"

# 17. textbox "Read file: ./terminal-menus.sh"
wait_s 0.5
enter
screenshot "12_textbox"

# 18. tailbox "Monitoring file: /var/log/acpid.log"
wait_s 1.0
enter
screenshot "13_tailbox"

# 19. tree "Choose a file from the tree" (default: "bin")
wait_s 1.0
enter
screenshot "14_tree"

# 20. msgbox "You chose: bin"
wait_s 0.5
enter

# 21. configtree "Choose your desired settings" (has 7 visible rows)
wait_s 1.0
enter
screenshot "15_configtree"

# 22. msgbox "You chose: ..."
wait_s 0.5
enter

# 23. form with DSL
wait_s 1.0
enter
screenshot "16_form"

# 24. msgbox "Data Received"
wait_s 0.5
enter

# 25. filepicker "Choose a file" (Escape to cancel)
wait_s 1.0
escape
screenshot "17_filepicker"

# 26. table "Pick an item"
wait_s 1.0
enter
screenshot "18_table"

# 27. msgbox "You chose: ..."
wait_s 0.5
enter

# 28. filtertable "Type to search, pick an item"
wait_s 1.0
enter
screenshot "19_filtertable"

# 29. msgbox "Selection Result"
wait_s 0.5
enter

# 30. filemanager "Advanced file manager" (q to quit)
wait_s 2.0
send_key q
screenshot "20_filemanager"

# 31. msgbox "You chose:" or "You quit..."
wait_s 0.5
enter

# 32. spreadsheet "Spreadsheet editor" (Escape to discard)
wait_s 1.0
escape
screenshot "21_spreadsheet"

# 33. msgbox "Spreadsheet Saved" or "Changes discarded"
wait_s 0.5
enter

# 34. kanban "Project" (q to quit) - this is fullscreen
wait_s 2.0
screenshot "22_kanban"
send_key q

# 35. mainmenu "Media center" (q to quit) - fullscreen with settings modals
wait_s 2.0
screenshot "23_mainmenu_initial"
send_key q
wait_s 0.5
screenshot "23_mainmenu_exit"

# 36. msgbox "TUI_RESULT" and "CONF_FILE" (if any)
wait_s 0.5
enter
wait_s 0.5
enter

# Done - wait for cleanup
wait_s 1.0

echo "=== Full Demo Test Complete ==="
