from testlib import TuiTestCase, KEY


class TestInputbox(TuiTestCase):
    def test_inputbox_accept_default(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("default_name", stdout)

    def test_inputbox_type_and_enter(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [
            KEY.char("m"), KEY.char("y"), KEY.char("v"),
            KEY.char("a"), KEY.char("l"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("default_namemyval", stdout)

    def test_inputbox_backspace(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [
            KEY.char("x"), KEY.BACKSPACE, KEY.char("y"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("default_namey", stdout)

    def test_inputbox_escape(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.ESCAPE])
        self.assert_exit(1, stdout)

    def test_inputbox_tab_skip(self):
        stdout, rc = self.runner("wrappers/inputbox_wrapper.sh", [KEY.TAB, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("default_name", stdout)
