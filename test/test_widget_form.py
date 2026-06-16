from testlib import TuiTestCase, KEY


class TestForm(TuiTestCase):
    def test_form_submit_defaults(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_in_output("user=", stdout)
        self.assert_in_output("wlan0", stdout)

    def test_form_tab_navigation(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [
            KEY.TAB, KEY.char("p"), KEY.char("w"),
            KEY.TAB, KEY.TAB, KEY.SPACE,
            KEY.TAB, KEY.SPACE,
            KEY.TAB, KEY.TAB, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_in_output("eth0='true'", stdout)

    def test_form_dropdown(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [
            KEY.TAB, KEY.TAB, KEY.TAB, KEY.SPACE,
            KEY.DOWN, KEY.ENTER, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)

    def test_form_tab_reverse(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [
            KEY.TAB, KEY.TAB, KEY.TAB, KEY.TAB, KEY.TAB,
            KEY.TAB, KEY.TAB, KEY.TAB, KEY.TAB, KEY.TAB,
            KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_form_checkbox_toggle(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [KEY.TAB, KEY.TAB, KEY.TAB, KEY.SPACE, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_form_escape_cancel(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [KEY.ESCAPE])
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_form_backspace_input(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [
            KEY.TAB, KEY.BACKSPACE, KEY.char("x"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_form_up_down_nav(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [
            KEY.DOWN, KEY.UP, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)
