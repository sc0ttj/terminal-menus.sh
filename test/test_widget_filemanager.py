from testlib import TuiTestCase, KEY


class TestFilemanager(TuiTestCase):
    def test_filemanager_q_quit(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [KEY.char("q")], timeout=10)
        self.assert_exit(1, stdout)

    def test_filemanager_vim_nav(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [
            KEY.char("j"), KEY.char("j"), KEY.char("k"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)

    def test_filemanager_enter_dir(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [
            KEY.DOWN, KEY.ENTER, KEY.char("h"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)

    def test_filemanager_search(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [
            KEY.char("/"), KEY.char("f"), KEY.char("i"),
            KEY.char("l"), KEY.char("e"), KEY.ENTER, KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)

    def test_filemanager_hidden_toggle(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [
            KEY.char("."), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)

    def test_filemanager_escape_quit(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [KEY.ESCAPE, KEY.ESCAPE], timeout=10)
        self.assert_no_shell_errors(stdout)

    def test_filemanager_detail_toggle(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [
            KEY.char(","), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filemanager_goto_home(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [
            KEY.char("~"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filemanager_gitignore_toggle(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [
            KEY.char("i"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filemanager_page_keys(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [
            KEY.char("J"), KEY.char("K"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filemanager_top_bottom(self):
        stdout, rc = self.runner("wrappers/filemanager_wrapper.sh", [
            KEY.char("g"), KEY.char("G"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)
