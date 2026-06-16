from testlib import TuiTestCase, KEY


class TestMsgbox(TuiTestCase):
    def test_msgbox_enter(self):
        stdout, rc = self.runner("wrappers/msgbox_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)

    def test_msgbox_content(self):
        stdout, rc = self.runner("wrappers/msgbox_wrapper.sh", [KEY.ENTER])
        self.assert_in_output("showcase of all widgets", stdout)

    def test_msgbox_title(self):
        stdout, rc = self.runner("wrappers/msgbox_wrapper.sh", [KEY.ENTER])
        self.assert_in_output("A widget with two buttons", stdout)

    def test_msgbox_custom_ok_label(self):
        stdout, rc = self.runner("wrappers/msgbox_custom_labels_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_centered_mode(self):
        stdout, rc = self.runner("wrappers/msgbox_layout_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_classic_mode(self):
        stdout, rc = self.runner("wrappers/msgbox_classic_mode_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_popup_mode(self):
        stdout, rc = self.runner("wrappers/msgbox_popup_mode_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_top_mode(self):
        stdout, rc = self.runner("wrappers/msgbox_top_mode_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_bottom_mode(self):
        stdout, rc = self.runner("wrappers/msgbox_bottom_mode_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_toast_mode(self):
        stdout, rc = self.runner("wrappers/msgbox_toast_mode_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_palette_mode(self):
        stdout, rc = self.runner("wrappers/msgbox_palette_mode_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_custom_mode(self):
        stdout, rc = self.runner("wrappers/msgbox_custom_mode_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_backtitle(self):
        stdout, rc = self.runner("wrappers/msgbox_backtitle_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_in_output("BACKTITLE", stdout)
        self.assert_no_shell_errors(stdout)

    def test_msgbox_color_theme(self):
        stdout, rc = self.runner("wrappers/msgbox_color_theme_wrapper.sh", [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)
