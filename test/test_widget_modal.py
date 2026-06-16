from testlib import TuiTestCase, KEY


class TestModal(TuiTestCase):
    def test_modal_msgbox(self):
        stdout, rc = self.runner("wrappers/modal_msgbox_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_in_output("modal", stdout)
        self.assert_no_shell_errors(stdout)

    def test_modal_no_shell_errors(self):
        stdout, rc = self.runner("wrappers/modal_msgbox_wrapper.sh", [KEY.ENTER])
        self.assert_no_shell_errors(stdout)
