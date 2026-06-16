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

    def test_checklist_select_all(self):
        stdout, rc = self.runner("wrappers/checklist_wrapper.sh", [
            KEY.SPACE, KEY.DOWN, KEY.SPACE, KEY.DOWN, KEY.SPACE, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_in_output("Option 1", stdout)
        self.assert_in_output("Option 2", stdout)
        self.assert_in_output("Option 3", stdout)
        self.assert_no_shell_errors(stdout)

    def test_checklist_toggle_off(self):
        stdout, rc = self.runner("wrappers/checklist_wrapper.sh", [
            KEY.SPACE, KEY.SPACE, KEY.DOWN, KEY.SPACE, KEY.SPACE, KEY.ENTER,
        ])
        self.assert_exit(0, stdout)
        self.assert_result("", stdout)
        self.assert_no_shell_errors(stdout)
