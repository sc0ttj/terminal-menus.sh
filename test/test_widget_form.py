from testlib import TuiTestCase, KEY


class TestForm(TuiTestCase):
    def test_form_submit_defaults(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_in_output("name=", stdout)
        self.assert_in_output("https='true'", stdout)

    def test_form_tab_navigation(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [
            KEY.TAB, KEY.char("p"), KEY.char("w"),
            KEY.TAB, KEY.TAB, KEY.SPACE,
            KEY.TAB, KEY.SPACE,
            KEY.TAB, KEY.TAB, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_in_output("ssh='true'", stdout)

    def test_form_dropdown(self):
        stdout, rc = self.runner("wrappers/form_wrapper.sh", [
            KEY.TAB, KEY.TAB, KEY.TAB, KEY.SPACE,
            KEY.DOWN, KEY.ENTER, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
