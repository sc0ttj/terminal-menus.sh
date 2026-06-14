from testlib import TuiTestCase, KEY


class TestFiltermenu(TuiTestCase):
    def test_filtermenu_enter_default(self):
        stdout, rc = self.runner("wrappers/filtermenu_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)

    def test_filtermenu_type_and_select(self):
        stdout, rc = self.runner("wrappers/filtermenu_wrapper.sh", [
            KEY.BACKSPACE, KEY.char("U"), KEY.char("S"),
            KEY.char("A"), KEY.ENTER, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("USA", stdout)

    def test_filtermenu_type_backspace(self):
        stdout, rc = self.runner("wrappers/filtermenu_wrapper.sh", [
            KEY.BACKSPACE, KEY.char("U"), KEY.BACKSPACE,
            KEY.char("U"), KEY.char("S"), KEY.char("A"), KEY.ENTER, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("USA", stdout)
