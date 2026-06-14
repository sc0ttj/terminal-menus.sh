from testlib import TuiTestCase, KEY


class TestChecklist(TuiTestCase):
    def test_checklist_enter_default(self):
        stdout, rc = self.runner("wrappers/checklist_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("", stdout)

    def test_checklist_space_two_items(self):
        stdout, rc = self.runner("wrappers/checklist_wrapper.sh", [
            KEY.SPACE, KEY.DOWN, KEY.SPACE, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_in_output("Option 1", stdout)
        self.assert_in_output("Option 2", stdout)

    def test_checklist_arrow_then_space(self):
        stdout, rc = self.runner("wrappers/checklist_wrapper.sh", [
            KEY.DOWN, KEY.SPACE, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("Option 2", stdout)
