from testlib import TuiTestCase, KEY


class TestTextbox(TuiTestCase):
    def test_textbox_enter_quit(self):
        stdout, rc = self.runner("wrappers/textbox_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)

    def test_textbox_q_quit(self):
        stdout, rc = self.runner("wrappers/textbox_wrapper.sh", [KEY.char("q")])
        self.assert_exit(0, stdout)

    def test_textbox_scroll_down(self):
        stdout, rc = self.runner("wrappers/textbox_wrapper.sh", [
            KEY.DOWN, KEY.DOWN, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)

    def test_textbox_scroll_vim(self):
        stdout, rc = self.runner("wrappers/textbox_wrapper.sh", [
            KEY.char("j"), KEY.char("j"), KEY.char("k"), KEY.char("q"),
        ])
        self.assert_exit(0, stdout)
