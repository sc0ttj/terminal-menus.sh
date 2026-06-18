from testlib import TuiTestCase, KEY


class TestFiltermenu(TuiTestCase):
    def test_filtermenu_enter_default(self):
        stdout, rc = self.runner("wrappers/filtermenu_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)

    def test_filtermenu_type_and_select(self):
        stdout, rc = self.runner("wrappers/filtermenu_wrapper.sh", [
            KEY.BACKSPACE, KEY.char("A"), KEY.char("l"),
            KEY.char("g"), KEY.ENTER, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("Algeria", stdout)

    def test_filtermenu_type_backspace(self):
        stdout, rc = self.runner("wrappers/filtermenu_wrapper.sh", [
            KEY.BACKSPACE, KEY.char("X"), KEY.BACKSPACE,
            KEY.char("A"), KEY.char("l"), KEY.char("g"), KEY.ENTER, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("Algeria", stdout)

    def test_filtermenu_down_and_select(self):
        stdout, rc = self.runner("wrappers/filtermenu_wrapper.sh", [
            KEY.BACKSPACE, KEY.DOWN, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filtermenu_tab_cycle(self):
        stdout, rc = self.runner("wrappers/filtermenu_wrapper.sh", [
            KEY.TAB, KEY.TAB, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filtermenu_cursor_left_right(self):
        stdout, rc = self.runner("wrappers/filtermenu_cursor_wrapper.sh", [
            KEY.BACKSPACE, KEY.char("A"), KEY.char("l"),
            KEY.LEFT, KEY.RIGHT, KEY.ENTER, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)
