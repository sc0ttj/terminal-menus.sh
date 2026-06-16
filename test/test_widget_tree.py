from testlib import TuiTestCase, KEY


class TestTree(TuiTestCase):
    def test_tree_enter_default(self):
        stdout, rc = self.runner("wrappers/tree_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("usr/bin", stdout)

    def test_tree_down_enter(self):
        stdout, rc = self.runner("wrappers/tree_wrapper.sh", [KEY.DOWN, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("usr/bin/bash", stdout)

    def test_tree_q_quit(self):
        stdout, rc = self.runner("wrappers/tree_wrapper.sh", [KEY.char("q")])
        self.assert_exit(1, stdout)

    def test_tree_filter_enabled(self):
        stdout, rc = self.runner("wrappers/tree_wrapper.sh", [KEY.char("b"), KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_tree_expand_and_select(self):
        stdout, rc = self.runner("wrappers/tree_wrapper.sh", [
            KEY.DOWN, KEY.DOWN, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_tree_nav_wrap(self):
        stdout, rc = self.runner("wrappers/tree_wrapper.sh", [
            KEY.UP, KEY.DOWN, KEY.char("q"),
        ])
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_tree_expand_with_right_arrow(self):
        stdout, rc = self.runner("wrappers/tree_expand_collapse_wrapper.sh", [
            KEY.DOWN, KEY.RIGHT, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_tree_collapse_with_left_arrow(self):
        stdout, rc = self.runner("wrappers/tree_expand_collapse_wrapper.sh", [
            KEY.DOWN, KEY.RIGHT, KEY.LEFT, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_tree_filter_disabled(self):
        stdout, rc = self.runner("wrappers/tree_filter_disabled_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)
