from testlib import TuiTestCase, KEY


class TestMsgbox(TuiTestCase):
    def test_msgbox_enter(self):
        stdout, rc = self.runner("wrappers/msgbox_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
