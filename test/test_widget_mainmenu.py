import re
from testlib import TuiTestCase, KEY


class TestMainmenu(TuiTestCase):
    def test_mainmenu_q_quit(self):
        stdout, rc = self.runner("wrappers/mainmenu_wrapper.sh", [KEY.char("q")], timeout=10)
        self.assert_exit(1, stdout)

    def test_mainmenu_tab_focus(self):
        stdout, rc = self.runner("wrappers/mainmenu_wrapper.sh", [
            KEY.TAB, KEY.ENTER, KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)

    def test_mainmenu_arrows(self):
        stdout, rc = self.runner("wrappers/mainmenu_wrapper.sh", [
            KEY.DOWN, KEY.RIGHT, KEY.DOWN, KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)

    def test_mainmenu_enter_execute(self):
        stdout, rc = self.runner("wrappers/mainmenu_wrapper.sh", [
            KEY.ENTER, KEY.ENTER, KEY.ENTER,
        ], timeout=10)
        self.assert_exit(0, stdout)
        self.assert_in_output("echo matrix", stdout)

    def test_mainmenu_sort_columns(self):
        stdout, rc = self.runner("wrappers/mainmenu_wrapper.sh", [
            KEY.TAB, KEY.ENTER, KEY.char("1"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self._assert_no_shell_errors(stdout)

    def test_mainmenu_sort_toggle(self):
        stdout, rc = self.runner("wrappers/mainmenu_wrapper.sh", [
            KEY.TAB, KEY.ENTER, KEY.char("1"), KEY.char("1"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self._assert_no_shell_errors(stdout)

    def test_mainmenu_sort_different_column(self):
        stdout, rc = self.runner("wrappers/mainmenu_wrapper.sh", [
            KEY.TAB, KEY.ENTER, KEY.char("2"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self._assert_no_shell_errors(stdout)

    def test_mainmenu_sort_sidebar_focus(self):
        stdout, rc = self.runner("wrappers/mainmenu_wrapper.sh", [
            KEY.char("1"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self._assert_no_shell_errors(stdout)

    def test_mainmenu_sort_column_beyond_range(self):
        stdout, rc = self.runner("wrappers/mainmenu_wrapper.sh", [
            KEY.TAB, KEY.ENTER, KEY.char("9"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self._assert_no_shell_errors(stdout)

    def test_mainmenu_sort_single_quotes(self):
        stdout, rc = self.runner("wrappers/mainmenu_quotes_wrapper.sh", [
            KEY.TAB, KEY.ENTER, KEY.char("1"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self._assert_no_shell_errors(stdout)
        self.assertNotIn("not found", stdout)

    def test_mainmenu_sort_integrity_asc(self):
        stdout, rc = self.runner("wrappers/mainmenu_multirow_wrapper.sh", [
            KEY.TAB, KEY.ENTER, KEY.char("1"), KEY.ENTER,
        ], timeout=10)
        self.assert_exit(0, stdout)
        self.assert_in_output("echo alpha", stdout)
        self._assert_no_shell_errors(stdout)

    def test_mainmenu_sort_integrity_desc(self):
        stdout, rc = self.runner("wrappers/mainmenu_multirow_wrapper.sh", [
            KEY.TAB, KEY.ENTER, KEY.char("1"), KEY.char("1"), KEY.ENTER,
        ], timeout=10)
        self.assert_exit(0, stdout)
        self.assert_in_output("echo zed", stdout)
        self._assert_no_shell_errors(stdout)

    def _assert_no_shell_errors(self, stdout):
        """Check that stdout contains no shell error patterns."""
        for pattern in ["Syntax error", "not found", "unexpected", "Bad substitution"]:
            self.assertNotIn(pattern, stdout, f"shell error pattern found: {pattern!r}")
