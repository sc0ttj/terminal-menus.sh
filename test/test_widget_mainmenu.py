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
