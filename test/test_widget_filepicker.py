from testlib import TuiTestCase, KEY


class TestFilepicker(TuiTestCase):
    def test_filepicker_enter_select(self):
        stdout, rc = self.runner("wrappers/filepicker_wrapper.sh", [KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)

    def test_filepicker_down_enter(self):
        stdout, rc = self.runner("wrappers/filepicker_wrapper.sh", [KEY.DOWN, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)

    def test_filepicker_q_quit(self):
        stdout, rc = self.runner("wrappers/filepicker_wrapper.sh", [KEY.char("q")], timeout=8)
        self.assert_exit(1, stdout)

    def test_filepicker_parent(self):
        stdout, rc = self.runner("wrappers/filepicker_wrapper.sh", [
            KEY.char("h"), KEY.char("q"),
        ], timeout=8)
        self.assert_exit(1, stdout)

    def test_filepicker_toggle_hidden(self):
        stdout, rc = self.runner("wrappers/filepicker_wrapper.sh", [
            KEY.char("."), KEY.char("q"),
        ], timeout=8)
        self.assert_exit(1, stdout)

    def test_filepicker_enter_no_crash(self):
        stdout, rc = self.runner("wrappers/filepicker_wrapper.sh", [KEY.ENTER], timeout=8)
        self.assert_no_shell_errors(stdout)

    def test_filepicker_multiselect_tab(self):
        stdout, rc = self.runner("wrappers/filepicker_multiselect_wrapper.sh", [
            KEY.TAB, KEY.DOWN, KEY.TAB, KEY.char("q"),
        ], timeout=8)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filepicker_vim_keys_w_s(self):
        stdout, rc = self.runner("wrappers/filepicker_wrapper.sh", [
            KEY.char("w"), KEY.char("s"), KEY.char("q"),
        ], timeout=8)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filepicker_right_key(self):
        stdout, rc = self.runner("wrappers/filepicker_wrapper.sh", [
            KEY.RIGHT, KEY.char("q"),
        ], timeout=8)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filepicker_cd_file(self):
        stdout, rc = self.runner("wrappers/filepicker_cd_file_wrapper.sh", [
            KEY.char("q"),
        ], timeout=8)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)
