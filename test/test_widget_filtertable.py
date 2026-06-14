from testlib import TuiTestCase, KEY


class TestFiltertable(TuiTestCase):
    def test_filtertable_enter_default(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)

    def test_filtertable_type_and_select(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [
            KEY.char("B"), KEY.char("e"), KEY.char("t"),
            KEY.char("a"), KEY.ENTER, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("echo beta", stdout)

    def test_filtertable_backspace(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [
            KEY.char("X"), KEY.BACKSPACE,
            KEY.char("A"), KEY.char("l"), KEY.char("p"),
            KEY.char("h"), KEY.char("a"), KEY.ENTER, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("echo alpha", stdout)

    def test_filtertable_escape_cancel(self):
        stdout, rc = self.runner("wrappers/filtertable_wrapper.sh", [KEY.ESCAPE])
        self.assert_exit(1, stdout)
