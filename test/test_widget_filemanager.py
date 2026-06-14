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
