from testlib import TuiTestCase


class TestGauge(TuiTestCase):
    def test_gauge_complete(self):
        stdout, rc = self.runner("wrappers/gauge_wrapper.sh", [], timeout=5)
        self.assert_exit(0, stdout)
        self.assert_in_output("100%", stdout)

    def test_gauge_output(self):
        stdout, rc = self.runner("wrappers/gauge_wrapper.sh", [], timeout=5)
        self.assert_in_output("complete", stdout)
