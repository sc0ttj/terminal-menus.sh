from testlib import TuiTestCase, KEY


class TestFiltertable(TuiTestCase):
    def test_filtertable_enter_default(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)

    def test_filtertable_type_filter_clear(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [
            KEY.TAB, KEY.char("X"), KEY.BACKSPACE,
            KEY.TAB, KEY.DOWN, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filtertable_arrow_nav(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [KEY.DOWN, KEY.DOWN, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filtertable_vim_nav(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [
            KEY.char("j"), KEY.char("j"), KEY.char("k"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filtertable_cursor_keys(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [
            KEY.LEFT, KEY.RIGHT, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filtertable_no_shell_errors(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [KEY.ENTER])
        self.assert_no_shell_errors(stdout)
