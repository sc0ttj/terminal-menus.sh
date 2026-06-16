from testlib import TuiTestCase, KEY


class TestKanban(TuiTestCase):
    def test_kanban_q_quit(self):
        stdout, rc = self.runner("wrappers/kanban_wrapper.sh", [KEY.char("q")], timeout=10)
        self.assert_exit(0, stdout)

    def test_kanban_vim_nav(self):
        stdout, rc = self.runner("wrappers/kanban_wrapper.sh", [
            KEY.char("l"), KEY.char("h"),
            KEY.char("j"), KEY.char("k"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(0, stdout)

    def test_kanban_arrow_nav(self):
        stdout, rc = self.runner("wrappers/kanban_wrapper.sh", [
            KEY.RIGHT, KEY.LEFT, KEY.DOWN, KEY.UP, KEY.char("q"),
        ], timeout=10)
        self.assert_exit(0, stdout)

    def test_kanban_help(self):
        stdout, rc = self.runner("wrappers/kanban_wrapper.sh", [
            KEY.char("?"), KEY.ENTER, KEY.char("q"),
        ], timeout=10)
        self.assert_exit(0, stdout)

    def test_kanban_q_quit_no_errors(self):
        stdout, rc = self.runner("wrappers/kanban_wrapper.sh", [KEY.char("q")], timeout=10)
        self.assert_no_shell_errors(stdout)

    def test_kanban_sort_toggle(self):
        stdout, rc = self.runner("wrappers/kanban_wrapper.sh", [
            KEY.char("o"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_kanban_sort_direction(self):
        stdout, rc = self.runner("wrappers/kanban_wrapper.sh", [
            KEY.char("O"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_kanban_move_right(self):
        stdout, rc = self.runner("wrappers/kanban_wrapper.sh", [
            KEY.char("L"), KEY.char("q"),
        ], timeout=10)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)
