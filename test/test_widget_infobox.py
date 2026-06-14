from testlib import TuiTestCase


class TestInfobox(TuiTestCase):
    def test_infobox_display(self):
        stdout, rc = self.runner("wrappers/infobox_wrapper.sh", [], timeout=3)
        self.assert_exit(0, stdout)
        self.assert_in_output("Info", stdout)

    def test_infobox_content(self):
        stdout, rc = self.runner("wrappers/infobox_wrapper.sh", [], timeout=3)
        self.assert_in_output("Non-blocking info message", stdout)
