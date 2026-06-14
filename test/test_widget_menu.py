from testlib import TuiTestCase, KEY


class TestMenu(TuiTestCase):
    def test_menu_enter_default(self):
        stdout, rc = self.runner("wrappers/menu_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Banana", stdout)

    def test_menu_down_second(self):
        stdout, rc = self.runner("wrappers/menu_wrapper.sh", [KEY.DOWN, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Cherry", stdout)

    def test_menu_down_down_third(self):
        stdout, rc = self.runner("wrappers/menu_wrapper.sh", [KEY.DOWN, KEY.DOWN, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Date", stdout)

    def test_menu_up_from_bottom(self):
        stdout, rc = self.runner("wrappers/menu_wrapper.sh", [
            KEY.DOWN, KEY.DOWN, KEY.DOWN, KEY.UP, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("Date", stdout)
