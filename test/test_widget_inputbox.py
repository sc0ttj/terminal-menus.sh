from testlib import TuiTestCase, KEY


class TestInputbox(TuiTestCase):
    def test_inputbox_accept_default(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("foo", stdout)

    def test_inputbox_type_and_enter(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [
            KEY.char("m"), KEY.char("y"), KEY.char("v"),
            KEY.char("a"), KEY.char("l"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("foomyval", stdout)

    def test_inputbox_backspace(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [
            KEY.char("x"), KEY.BACKSPACE, KEY.char("y"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("fooy", stdout)

    def test_inputbox_escape(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.ESCAPE])
        self.assert_exit(1, stdout)

    def test_inputbox_tab_skip(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.TAB, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("foo", stdout)

    def test_inputbox_delete(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.RIGHT, KEY.DELETE, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_inputbox_type_text(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.char("x"), KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_inputbox_arrow_nav(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.LEFT, KEY.LEFT, KEY.RIGHT, KEY.RIGHT, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_inputbox_no_shell_errors(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.ENTER])
        self.assert_no_shell_errors(stdout)
