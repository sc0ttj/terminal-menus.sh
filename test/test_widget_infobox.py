from testlib import TuiTestCase


class TestInfobox(TuiTestCase):
    def test_infobox_display(self):
        stdout, rc = self.runner("wrappers/infobox_wrapper.sh", [], timeout=3)
        self.assert_exit(0, stdout)
        self.assert_in_output("Welcome", stdout)

    def test_infobox_content(self):
        stdout, rc = self.runner("wrappers/infobox_wrapper.sh", [], timeout=3)
        self.assert_in_output("Please wait", stdout)

    def test_infobox_no_backtitle_crash(self):
        stdout, rc = self.runner("wrappers/infobox_wrapper.sh", [], timeout=3)
        self.assert_no_shell_errors(stdout)

    def test_infobox_backtitle(self):
        stdout, rc = self.runner("wrappers/infobox_wrapper.sh", [], timeout=3)
        self.assert_in_output("terminal-menus.sh", stdout)
