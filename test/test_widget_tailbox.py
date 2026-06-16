from testlib import TuiTestCase, KEY


class TestTailbox(TuiTestCase):
    def test_tailbox_enter_quit(self):
        stdout, rc = self.runner("wrappers/tailbox_wrapper.sh", [KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)

    def test_tailbox_content(self):
        stdout, rc = self.runner("wrappers/tailbox_wrapper.sh", [KEY.ENTER], timeout=8)
        self.assert_in_output("apt-daily", stdout)

    def test_tailbox_enter_quit_content(self):
        stdout, rc = self.runner("wrappers/tailbox_wrapper.sh", [KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)
