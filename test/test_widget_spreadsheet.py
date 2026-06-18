from testlib import TuiTestCase, KEY


class TestSpreadsheet(TuiTestCase):
    def test_spreadsheet_q_quit(self):
        stdout, rc = self.runner("wrappers/spreadsheet_wrapper.sh", [KEY.char("q")], timeout=8)
        self.assert_exit(0, stdout)

    def test_spreadsheet_nav_vim_keys(self):
        stdout, rc = self.runner("wrappers/spreadsheet_wrapper.sh", [
            KEY.char("j"), KEY.char("j"), KEY.char("k"),
            KEY.char("l"), KEY.char("h"), KEY.char("q"),
        ], timeout=8)
        self.assert_exit(0, stdout)

    def test_spreadsheet_edit_cell(self):
        stdout, rc = self.runner("wrappers/spreadsheet_wrapper.sh", [
            KEY.ENTER, KEY.char("9"), KEY.char("9"), KEY.ENTER, KEY.char("q"),
        ], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_in_output("99", stdout)

    def test_spreadsheet_copy_paste(self):
        stdout, rc = self.runner("wrappers/spreadsheet_wrapper.sh", [
            KEY.char("c"), KEY.char("j"), KEY.char("v"), KEY.char("q"),
        ], timeout=8)
        self.assert_exit(0, stdout)

    def test_spreadsheet_undo(self):
        stdout, rc = self.runner("wrappers/spreadsheet_wrapper.sh", [
            KEY.ENTER, KEY.char("X"), KEY.ENTER, KEY.char("z"), KEY.char("q"),
        ], timeout=8)
        self.assert_exit(0, stdout)

    def test_spreadsheet_q_quit_no_errors(self):
        stdout, rc = self.runner("wrappers/spreadsheet_wrapper.sh", [KEY.char("q")], timeout=8)
        self.assert_no_shell_errors(stdout)

    def test_spreadsheet_arrow_nav(self):
        stdout, rc = self.runner("wrappers/spreadsheet_extra_wrapper.sh", [
            KEY.DOWN, KEY.RIGHT, KEY.UP, KEY.LEFT, KEY.char("q"),
        ], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_spreadsheet_cut(self):
        stdout, rc = self.runner("wrappers/spreadsheet_wrapper.sh", [
            KEY.char("x"), KEY.char("j"), KEY.char("v"), KEY.char("q"),
        ], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_spreadsheet_redo(self):
        stdout, rc = self.runner("wrappers/spreadsheet_wrapper.sh", [
            KEY.ENTER, KEY.char("X"), KEY.ENTER, KEY.char("z"),
            KEY.char("Z"), KEY.char("q"),
        ], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_spreadsheet_edit_special_chars(self):
        stdout, rc = self.runner("wrappers/spreadsheet_wrapper.sh", [
            KEY.ENTER,
            KEY.char("="),
            KEY.char("!"),
            KEY.char("("),
            KEY.ENTER,
            KEY.char("q"),
        ], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)
