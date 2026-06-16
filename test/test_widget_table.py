from testlib import TuiTestCase, KEY


class TestTable(TuiTestCase):
    def test_table_enter_default(self):
        stdout, rc = self.runner("wrappers/table_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result('tailbox "System" "/var/log/syslog"', stdout)

    def test_table_j_enter(self):
        stdout, rc = self.runner("wrappers/table_wrapper.sh", [KEY.char("j"), KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result('echo "MySQL is down"', stdout)

    def test_table_k_enter(self):
        stdout, rc = self.runner("wrappers/table_wrapper.sh", [
            KEY.char("j"), KEY.char("j"), KEY.char("k"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result('echo "MySQL is down"', stdout)

    def test_table_down_enter(self):
        stdout, rc = self.runner("wrappers/table_wrapper.sh", [KEY.DOWN, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result('echo "MySQL is down"', stdout)

    def test_table_jk_nav(self):
        stdout, rc = self.runner("wrappers/table_wrapper.sh", [
            KEY.char("j"), KEY.char("j"), KEY.char("k"), KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result('echo "MySQL is down"', stdout)
        self.assert_no_shell_errors(stdout)

    def test_table_arrow_down_then_up(self):
        stdout, rc = self.runner("wrappers/table_wrapper.sh", [
            KEY.DOWN, KEY.DOWN, KEY.UP, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result('echo "MySQL is down"', stdout)
        self.assert_no_shell_errors(stdout)
