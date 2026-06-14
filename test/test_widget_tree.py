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

    def test_tree_expand_collapse(self):
        stdout, rc = self.runner("wrappers/tree_wrapper.sh", [
            KEY.RIGHT, KEY.DOWN, KEY.RIGHT, KEY.DOWN, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("usr/share", stdout)

    def test_tree_q_quit(self):
        stdout, rc = self.runner("wrappers/tree_wrapper.sh", [KEY.char("q")])
        self.assert_exit(1, stdout)
