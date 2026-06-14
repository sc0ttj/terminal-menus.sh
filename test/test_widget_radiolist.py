from testlib import TuiTestCase, KEY


class TestRadiolist(TuiTestCase):
    def test_radiolist_enter_default(self):
        stdout, rc = self.runner("wrappers/radiolist_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Medium", stdout)

    def test_radiolist_down_enter(self):
        stdout, rc = self.runner("wrappers/radiolist_wrapper.sh", [KEY.DOWN, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Medium", stdout)

    def test_radiolist_space_select(self):
        stdout, rc = self.runner("wrappers/radiolist_wrapper.sh", [KEY.SPACE, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Medium", stdout)

    def test_radiolist_down_space(self):
        stdout, rc = self.runner("wrappers/radiolist_wrapper.sh", [
            KEY.DOWN, KEY.SPACE, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("High", stdout)
