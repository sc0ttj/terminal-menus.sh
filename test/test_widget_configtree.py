from testlib import TuiTestCase, KEY


class TestConfigtree(TuiTestCase):
    def test_configtree_enter_default(self):
        stdout, rc = self.runner("wrappers/configtree_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_in_output("RESULT=", stdout)

    def test_configtree_toggle(self):
        stdout, rc = self.runner("wrappers/configtree_wrapper.sh", [
            KEY.DOWN, KEY.DOWN, KEY.SPACE, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_in_output("dhcp=", stdout)

    def test_configtree_quit(self):
        stdout, rc = self.runner("wrappers/configtree_wrapper.sh", [KEY.char("q")])
        self.assert_exit(1, stdout)
