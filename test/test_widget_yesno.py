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

    def test_yesno_custom_labels(self):
        stdout, rc = self.runner("wrappers/yesno_custom_labels_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_yesno_left_arrow_yes(self):
        stdout, rc = self.runner("wrappers/yesno_wrapper.sh", [KEY.LEFT, KEY.RIGHT, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("true", stdout)
        self.assert_no_shell_errors(stdout)

    def test_yesno_theme(self):
        stdout, rc = self.runner("wrappers/yesno_theme_wrapper.sh", [KEY.LEFT, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_yesno_modes(self):
        stdout, rc = self.runner("wrappers/yesno_modes_wrapper.sh", [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)
