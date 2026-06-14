from testlib import TuiTestCase, KEY


class TestYesno(TuiTestCase):
    def test_yesno_enter_yes(self):
        stdout, rc = self.runner("wrappers/yesno_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("true", stdout)

    def test_yesno_arrow_no(self):
        stdout, rc = self.runner("wrappers/yesno_wrapper.sh", [KEY.RIGHT, KEY.ENTER])
        self.assert_exit(1, stdout)
        self.assert_result("false", stdout)

    def test_yesno_left_arrow_no(self):
        stdout, rc = self.runner("wrappers/yesno_wrapper.sh", [KEY.LEFT, KEY.ENTER])
        self.assert_exit(1, stdout)
        self.assert_result("false", stdout)
