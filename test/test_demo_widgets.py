"""Demo-driven PTY integration tests for terminal-menus widgets.

Each widget gets one test class that exercises the ``terminal-menus-demo.sh``
``demo_<widget>`` function end-to-end.  Tests feed keystrokes via a shared
PTY session (one per class) and assert on the ``EXIT=``/``RESULT=`` markers
as well as visible terminal output.

Usage::

    python3 -m unittest test.test_demo_widgets -v
    python3 -m unittest test.test_demo_widgets.TestMenu -v
"""

from testlib import TuiTestCase, KEY

# ────────────────────────────────────────────────────────────────────
# 1.  Info Box (auto-dismiss, non-blocking)
# ────────────────────────────────────────────────────────────────────
class TestInfobox(TuiTestCase):
    def test_display(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh infobox",
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_in_output("Welcome", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 2.  Message Box
# ────────────────────────────────────────────────────────────────────
class TestMsgbox(TuiTestCase):
    def test_ok(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh msgbox",
                                 [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_in_output("two buttons", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 3.  Yes/No  (two sub-demos: yesno_modes + yesno_theming)
# ────────────────────────────────────────────────────────────────────
class TestYesno(TuiTestCase):
    def test_full_flow(self):
        """11 ENTERs: 1 intro msgbox + 8 modes + 1 closing msgbox + 1 theming default NO"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh yesno",
                                 [KEY.ENTER] * 11, timeout=10)
        self.assert_exit(0, stdout)
        self.assert_in_output("Thats all the modes", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 4.  Input Box
# ────────────────────────────────────────────────────────────────────
class TestInputbox(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh inputbox",
                                 [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("foo", stdout)
        self.assert_no_shell_errors(stdout)

    def test_type_text(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh inputbox",
                                 [KEY.BACKSPACE] * 3
                                 + [KEY.text("bar"), KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("bar", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 5.  Password Box
# ────────────────────────────────────────────────────────────────────
class TestPasswordbox(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh passwordbox",
                                 [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("ppp", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 6.  Menu (followed by msgbox showing the choice)
# ────────────────────────────────────────────────────────────────────
class TestMenu(TuiTestCase):
    def test_default(self):
        """Accept default (Banana at index 2), dismiss follow-up msgbox"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Banana", stdout)
        self.assert_no_shell_errors(stdout)

    def test_down_then_accept(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.DOWN, KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Cherry", stdout)
        self.assert_no_shell_errors(stdout)

    def test_wrap_around(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.DOWN] * 3 + [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 7.  Checklist (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestChecklist(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh checklist",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Option 2", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 8.  Radiolist (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestRadiolist(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh radiolist",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Medium", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 9.  Filtermenu (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestFiltermenu(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtermenu",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Australia", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 10. Gauge (auto-pipe, no keys needed)
# ────────────────────────────────────────────────────────────────────
class TestGauge(TuiTestCase):
    def test_progress(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh gauge",
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 11. Textbox (file viewer, ENTER to quit)
# ────────────────────────────────────────────────────────────────────
class TestTextbox(TuiTestCase):
    def test_enter_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh textbox",
                                 [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 12. Tailbox (live monitor, ENTER to quit)
# ────────────────────────────────────────────────────────────────────
class TestTailbox(TuiTestCase):
    def test_enter_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tailbox",
                                 [KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)


# ────────────────────────────────────────────────────────────────────
# 13. Tree (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestTree(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tree",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("usr/bin", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 14. Configtree (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestConfigtree(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh configtree",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 15. Form (followed by msgbox showing parsed data)
# ────────────────────────────────────────────────────────────────────
class TestForm(TuiTestCase):
    def test_submit_defaults(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh form",
                                 [KEY.ENTER, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_in_output("User:", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 16. Filepicker (ESC to quit)
# ────────────────────────────────────────────────────────────────────
class TestFilepicker(TuiTestCase):
    def test_q_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filepicker",
                                 [KEY.char("q")])
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 17. Table (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestTable(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh table",
                                 [KEY.ENTER, KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 18. Filterable Table (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestFiltertable(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtertable",
                                 [KEY.ENTER, KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 19. File Manager
# ────────────────────────────────────────────────────────────────────
class TestFilemanager(TuiTestCase):
    def test_q_quit(self):
        """Press 'q' to quit, then ENTER to dismiss follow-up msgbox"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filemanager",
                                 [KEY.char("q"), KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_navigate_then_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filemanager",
                                 [KEY.char("j"), KEY.char("k"),
                                  KEY.char("q"), KEY.ENTER],
                                 timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 20. Spreadsheet
# ────────────────────────────────────────────────────────────────────
class TestSpreadsheet(TuiTestCase):
    def test_q_save(self):
        """'q' to save and quit, ENTER to dismiss follow-up msgbox"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh spreadsheet",
                                 [KEY.char("q"), KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_in_output("Saved", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 21. Kanban Board
# ────────────────────────────────────────────────────────────────────
class TestKanban(TuiTestCase):
    def test_q_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh kanban",
                                 [KEY.char("q")], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 22. Main Menu (Kodi-style split pane)
# ────────────────────────────────────────────────────────────────────
class TestMainmenu(TuiTestCase):
    def test_q_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh mainmenu",
                                 [KEY.char("q")])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)