from testlib import TuiTestCase, KEY


class TestMsgbox(TuiTestCase):
    def test_msgbox_enter(self):
        stdout, rc = self.runner("wrappers/msgbox_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)

    def test_msgbox_content(self):
        stdout, rc = self.runner("wrappers/msgbox_wrapper.sh", [KEY.ENTER])
        self.assert_in_output("Test message body here", stdout)

    def test_msgbox_title(self):
        stdout, rc = self.runner("wrappers/msgbox_wrapper.sh", [KEY.ENTER])
        self.assert_in_output("Test Title", stdout)
