from testlib import TuiTestCase


class TestGauge(TuiTestCase):
    def test_gauge_complete(self):
        stdout, rc = self.runner("wrappers/gauge_wrapper.sh", [], timeout=5)
        self.assert_exit(0, stdout)
        self.assert_in_output("100%", stdout)

    def test_gauge_output(self):
        stdout, rc = self.runner("wrappers/gauge_wrapper.sh", [], timeout=5)
        self.assert_in_output("complete", stdout)

    def test_gauge_no_shell_errors(self):
        stdout, rc = self.runner("wrappers/gauge_wrapper.sh", [], timeout=3)
        self.assert_no_shell_errors(stdout)

    def test_gauge_backtitle(self):
        stdout, rc = self.runner("wrappers/gauge_wrapper.sh", [], timeout=5)
        self.assert_in_output("Uploading", stdout)
