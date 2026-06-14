from testlib import TuiTestCase, KEY


class TestPasswordbox(TuiTestCase):
    def test_passwordbox_accept_default(self):
        stdout, rc = self.runner("wrappers/passwordbox_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("secret123", stdout)

    def test_passwordbox_type_and_enter(self):
        stdout, rc = self.runner("wrappers/passwordbox_wrapper.sh", [
            KEY.char("n"), KEY.char("e"), KEY.char("w"),
            KEY.char("p"), KEY.char("w"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_in_output("secret123newpw", stdout)

    def test_passwordbox_backspace(self):
        stdout, rc = self.runner("wrappers/passwordbox_wrapper.sh", [
            KEY.BACKSPACE, KEY.BACKSPACE, KEY.char("X"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("secret1X", stdout)

    def test_passwordbox_escape(self):
        stdout, rc = self.runner("wrappers/passwordbox_wrapper.sh", [KEY.ESCAPE])
        self.assert_exit(1, stdout)
