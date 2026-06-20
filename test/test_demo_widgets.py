"""Demo-driven PTY integration tests for terminal-menus widgets.

Each widget gets one test class that exercises the ``terminal-menus-demo.sh``
``demo_<widget>`` function end-to-end.  Tests feed keystrokes via a shared
PTY session (one per class) and assert on the ``EXIT=``/``RESULT=`` markers
as well as visible terminal output.

Usage::

    python3 -m unittest test.test_demo_widgets -v
    python3 -m unittest test.test_demo_widgets.TestMenu -v
"""

from testlib import TuiTestCase, KEY

# ────────────────────────────────────────────────────────────────────
# 1.  Info Box (auto-dismiss, non-blocking)
# ────────────────────────────────────────────────────────────────────
class TestInfobox(TuiTestCase):
    def test_display(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh infobox",
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_in_output("Welcome", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 2.  Message Box
# ────────────────────────────────────────────────────────────────────
class TestMsgbox(TuiTestCase):
    def test_ok(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh msgbox",
                                 [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_in_output("two buttons", stdout)
        self.assert_in_output("Let's Go!", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 3.  Yes/No  (two sub-demos: yesno_modes + yesno_theming)
# ────────────────────────────────────────────────────────────────────
class TestYesno(TuiTestCase):
    def test_full_flow(self):
        """11 ENTERs: 1 intro msgbox + 8 modes + 1 closing msgbox + 1 theming default NO"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh yesno",
                                 [KEY.ENTER] * 11, timeout=10)
        self.assert_exit(0, stdout)
        self.assert_in_output("Thats all the modes", stdout)
        self.assert_in_output("Indeed", stdout)
        self.assert_in_output("Not really", stdout)
        self.assert_no_shell_errors(stdout)

    def test_custom_labels(self):
        """Run theming demo only: custom YES_LABEL/NO_LABEL + default NO focus"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh yesno",
                                 [KEY.ENTER] * 11, timeout=10)
        self.assert_in_output("Indeed", stdout)
        self.assert_in_output("Not really", stdout)

    def test_left_right_focus(self):
        """Run all modes, pressing RIGHT on first yesno switches to NO focus"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh yesno",
                                 [KEY.ENTER,  KEY.RIGHT, KEY.ENTER,
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER,
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER,
                                  KEY.ENTER, KEY.ENTER],
                                 timeout=10)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 4.  Input Box
# ────────────────────────────────────────────────────────────────────
class TestInputbox(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh inputbox",
                                 [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("foo", stdout)
        self.assert_no_shell_errors(stdout)

    def test_type_text(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh inputbox",
                                 [KEY.BACKSPACE] * 3
                                 + [KEY.text("bar"), KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("bar", stdout)
        self.assert_no_shell_errors(stdout)

    def test_esc_cancel(self):
        stdout, rc = self.runner("wrappers/inputbox_esc.sh",
                                 [KEY.ESCAPE], timeout=6)
        self.assert_in_output("EXIT=1", stdout)
        self.assert_in_output("RESULT=", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 5.  Password Box
# ────────────────────────────────────────────────────────────────────
class TestPasswordbox(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh passwordbox",
                                 [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("ppp", stdout)
        self.assert_no_shell_errors(stdout)

    def test_type_text(self):
        stdout, rc = self.runner("wrappers/passwordbox_type.sh",
                                 [KEY.text("secret"), KEY.ENTER],
                                 timeout=6)
        self.assert_exit(0, stdout)
        self.assert_result("secret", stdout)
        self.assert_no_shell_errors(stdout)

    def test_esc_cancel(self):
        stdout, rc = self.runner("wrappers/passwordbox_esc.sh",
                                 [KEY.ESCAPE], timeout=6)
        self.assert_in_output("EXIT=1", stdout)
        self.assert_in_output("RESULT=", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 6.  Menu (followed by msgbox showing the choice)
# ────────────────────────────────────────────────────────────────────
class TestMenu(TuiTestCase):
    def test_default(self):
        """Accept default (Banana at index 2), dismiss follow-up msgbox"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Banana", stdout)
        self.assert_no_shell_errors(stdout)

    def test_down_then_accept(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.DOWN, KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Cherry", stdout)
        self.assert_no_shell_errors(stdout)

    def test_wrap_around(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.DOWN] * 3 + [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.PAGE_DOWN, KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_up(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.PAGE_DOWN, KEY.PAGE_UP,
                                  KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.END, KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Cherry", stdout)
        self.assert_no_shell_errors(stdout)

    def test_j_key_page(self):
        """'J' acts as Page Down"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.char("J"), KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_k_key_page_up(self):
        """'K' acts as Page Up"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.PAGE_DOWN, KEY.char("K"),
                                  KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_g_key_home(self):
        """'g' jumps to first item (Apple)"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.char("g"), KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Apple", stdout)
        self.assert_no_shell_errors(stdout)

    def test_G_key_end(self):
        """'G' jumps to last item (Cherry)"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.char("G"), KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Cherry", stdout)
        self.assert_no_shell_errors(stdout)

    def test_s_key_down(self):
        """'s' moves down one item (Banana -> Cherry)"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh menu",
                                 [KEY.char("s"), KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Cherry", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 7.  Checklist (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestChecklist(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh checklist",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Option 2", stdout)
        self.assert_no_shell_errors(stdout)

    def test_space_toggle(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh checklist",
                                 [KEY.SPACE, KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_multi_select(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh checklist",
                                 [KEY.DOWN, KEY.SPACE,
                                  KEY.UP, KEY.SPACE,
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_toggle_deselect(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh checklist",
                                 [KEY.SPACE, KEY.SPACE,
                                  KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Option 2", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 8.  Radiolist (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestRadiolist(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh radiolist",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Medium", stdout)
        self.assert_no_shell_errors(stdout)

    def test_space_select_first(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh radiolist",
                                 [KEY.UP, KEY.SPACE,
                                  KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Low", stdout)
        self.assert_no_shell_errors(stdout)

    def test_down_then_select(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh radiolist",
                                 [KEY.DOWN, KEY.SPACE,
                                  KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("High", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 9.  Filtermenu (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestFiltermenu(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtermenu",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("Australia", stdout)
        self.assert_no_shell_errors(stdout)

    def test_type_to_filter(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtermenu",
                                 [KEY.char("/"), KEY.text("United K"),
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_result("United Kingdom", stdout)
        self.assert_no_shell_errors(stdout)

    def test_filter_then_down(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtermenu",
                                 [KEY.char("/"), KEY.text("Can"),
                                  KEY.DOWN, KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_partial_match(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtermenu",
                                 [KEY.char("/"), KEY.text("Alge"),
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_result("Algeria", stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtermenu",
                                 [KEY.PAGE_DOWN, KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_up(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtermenu",
                                 [KEY.PAGE_DOWN, KEY.PAGE_UP,
                                  KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtermenu",
                                 [KEY.END, KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 10. Gauge (auto-pipe, no keys needed)
# ────────────────────────────────────────────────────────────────────
class TestGauge(TuiTestCase):
    def test_progress(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh gauge",
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 11. Textbox (file viewer, ENTER to quit)
# ────────────────────────────────────────────────────────────────────
class TestTextbox(TuiTestCase):
    def test_enter_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh textbox",
                                 [KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_scroll_down(self):
        stdout, rc = self.runner("wrappers/textbox_scroll.sh",
                                 [KEY.char("j")] * 5 + [KEY.ENTER],
                                 timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_scroll_up(self):
        stdout, rc = self.runner("wrappers/textbox_scroll.sh",
                                 [KEY.char("j")] * 20
                                 + [KEY.char("k")] * 10
                                 + [KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/textbox_scroll.sh",
                                 [KEY.PAGE_DOWN, KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/textbox_scroll.sh",
                                 [KEY.END, KEY.HOME, KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 12. Tailbox (live monitor, ENTER to quit)
# ────────────────────────────────────────────────────────────────────
class TestTailbox(TuiTestCase):
    def test_enter_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tailbox",
                                 [KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)


# ────────────────────────────────────────────────────────────────────
# 13. Tree (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestTree(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tree",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_result("usr/bin", stdout)
        self.assert_no_shell_errors(stdout)

    def test_q_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tree",
                                 [KEY.char("q"), KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_expand_node(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tree",
                                 [KEY.RIGHT, KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filter_typing(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tree",
                                 [KEY.char("/"),
                                  KEY.text("lib"),
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tree",
                                 [KEY.PAGE_DOWN, KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tree",
                                 [KEY.DOWN, KEY.HOME,
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_result("usr", stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_up(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tree",
                                 [KEY.PAGE_DOWN, KEY.PAGE_UP,
                                  KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_end(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh tree",
                                 [KEY.END, KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 14. Configtree (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestConfigtree(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh configtree",
                                 [KEY.ENTER, KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_space_toggle(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh configtree",
                                 [KEY.SPACE, KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_filter_typing(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh configtree",
                                 [KEY.char("/"),
                                  KEY.text("web"),
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh configtree",
                                 [KEY.PAGE_DOWN, KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_up(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh configtree",
                                 [KEY.PAGE_DOWN, KEY.PAGE_UP,
                                  KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh configtree",
                                 [KEY.END, KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 15. Form (followed by msgbox showing parsed data)
# ────────────────────────────────────────────────────────────────────
class TestForm(TuiTestCase):
    def test_submit_defaults(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh form",
                                 [KEY.ENTER, KEY.ENTER, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_in_output("User:", stdout)
        self.assert_no_shell_errors(stdout)

    def test_tab_cycling(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh form",
                                 [KEY.TAB, KEY.TAB,
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_in_output("User:", stdout)
        self.assert_no_shell_errors(stdout)

    def test_dropdown_space(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh form",
                                 [KEY.TAB, KEY.TAB, KEY.TAB,
                                  KEY.SPACE, KEY.DOWN, KEY.SPACE,
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER], timeout=10)
        self.assert_exit(0, stdout)
        self.assert_in_output("User:", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 16. Filepicker (ESC to quit)
# ────────────────────────────────────────────────────────────────────
class TestFilepicker(TuiTestCase):
    def test_q_quit(self):
        stdout, rc = self.runner("wrappers/filepicker_nav.sh",
                                 [KEY.char("q")], timeout=6)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_toggle_hidden(self):
        stdout, rc = self.runner("wrappers/filepicker_nav.sh",
                                 [KEY.char("."), KEY.char("q")],
                                 timeout=6)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/filepicker_nav.sh",
                                 [KEY.PAGE_DOWN, KEY.char("q")],
                                 timeout=6)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/filepicker_nav.sh",
                                 [KEY.END, KEY.PAGE_UP,
                                  KEY.char("q")], timeout=6)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 17. Table (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestTable(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh table",
                                 [KEY.ENTER, KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_scroll_and_select(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh table",
                                 [KEY.DOWN] * 5 + [KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_j_key_scroll(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh table",
                                 [KEY.char("j")] * 10
                                 + [KEY.ENTER, KEY.ENTER, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh table",
                                 [KEY.PAGE_DOWN, KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh table",
                                 [KEY.END, KEY.ENTER, KEY.ENTER, KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_up(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh table",
                                 [KEY.PAGE_DOWN, KEY.PAGE_UP,
                                  KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh table",
                                 [KEY.END, KEY.HOME,
                                  KEY.ENTER, KEY.ENTER],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 18. Filterable Table (followed by msgbox)
# ────────────────────────────────────────────────────────────────────
class TestFiltertable(TuiTestCase):
    def test_default(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtertable",
                                 [KEY.ENTER, KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_type_to_filter(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtertable",
                                 [KEY.TAB, KEY.text("My"),
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_in_output("The table returned:", stdout)
        self.assert_no_shell_errors(stdout)

    def test_filter_then_scroll(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtertable",
                                 [KEY.TAB, KEY.text("N"),
                                  KEY.DOWN, KEY.DOWN,
                                  KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtertable",
                                 [KEY.PAGE_DOWN, KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_up(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtertable",
                                 [KEY.PAGE_DOWN, KEY.PAGE_UP,
                                  KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtertable",
                                 [KEY.END, KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_slash_focus_filter(self):
        """'/' focuses filter input in filtertable"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filtertable",
                                 [KEY.char("/"), KEY.text("My"),
                                  KEY.ENTER, KEY.ENTER, KEY.ENTER],
                                 timeout=8, init_delay=0.3)
        self.assert_exit(0, stdout)
        self.assert_in_output("The table returned:", stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 19. File Manager
# ────────────────────────────────────────────────────────────────────
class TestFilemanager(TuiTestCase):
    def test_q_quit(self):
        """Press 'q' to quit, then ENTER to dismiss follow-up msgbox"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filemanager",
                                 [KEY.char("q"), KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_navigate_then_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filemanager",
                                 [KEY.char("j"), KEY.char("k"),
                                  KEY.char("q"), KEY.ENTER],
                                 timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_toggle_hidden(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filemanager",
                                 [KEY.char("."), KEY.char("q"),
                                  KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_enter_dir(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filemanager",
                                 [KEY.RIGHT, KEY.char("q"),
                                  KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filemanager",
                                 [KEY.PAGE_DOWN, KEY.char("q"),
                                  KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh filemanager",
                                 [KEY.PAGE_DOWN, KEY.HOME,
                                  KEY.char("q"), KEY.ENTER], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 20. Spreadsheet
# ────────────────────────────────────────────────────────────────────
class TestSpreadsheet(TuiTestCase):
    def test_q_save(self):
        """'q' to save and quit, ENTER to dismiss follow-up msgbox"""
        stdout, rc = self.runner("wrappers/demo_wrapper.sh spreadsheet",
                                 [KEY.char("q"), KEY.ENTER])
        self.assert_exit(0, stdout)
        self.assert_in_output("Saved", stdout)
        self.assert_no_shell_errors(stdout)

    def test_arrow_nav(self):
        stdout, rc = self.runner("wrappers/spreadsheet_nav.sh",
                                 [KEY.DOWN, KEY.RIGHT,
                                  KEY.char("q"), KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_w_key_nav(self):
        stdout, rc = self.runner("wrappers/spreadsheet_nav.sh",
                                 [KEY.char("w"), KEY.char("d"),
                                  KEY.char("q"), KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/spreadsheet_nav.sh",
                                 [KEY.HOME, KEY.END,
                                  KEY.char("q"), KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/spreadsheet_nav.sh",
                                 [KEY.PAGE_DOWN,
                                  KEY.char("q"), KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_up(self):
        stdout, rc = self.runner("wrappers/spreadsheet_nav.sh",
                                 [KEY.PAGE_DOWN, KEY.PAGE_UP,
                                  KEY.char("q"), KEY.ENTER], timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 21. Kanban Board
# ────────────────────────────────────────────────────────────────────
class TestKanban(TuiTestCase):
    def test_q_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh kanban",
                                 [KEY.char("q")], timeout=6)
        self.assert_exit(0, stdout)
        self.assert_result("1", stdout)
        self.assert_no_shell_errors(stdout)

    def test_arrow_nav(self):
        stdout, rc = self.runner("wrappers/kanban_nav.sh",
                                 [KEY.DOWN, KEY.RIGHT,
                                  KEY.char("q")], timeout=8)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/kanban_nav.sh",
                                 [KEY.PAGE_DOWN,
                                  KEY.char("q")], timeout=8)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/kanban_nav.sh",
                                 [KEY.END, KEY.HOME,
                                  KEY.char("q")], timeout=8)
        self.assert_exit(1, stdout)
        self.assert_no_shell_errors(stdout)


# ────────────────────────────────────────────────────────────────────
# 22. Main Menu (Kodi-style split pane)
# ────────────────────────────────────────────────────────────────────
class TestMainmenu(TuiTestCase):
    def test_q_quit(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh mainmenu",
                                 [KEY.char("q")])
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_down(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh mainmenu",
                                 [KEY.PAGE_DOWN, KEY.char("q")],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_page_up(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh mainmenu",
                                 [KEY.PAGE_DOWN, KEY.PAGE_UP,
                                  KEY.char("q")],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)

    def test_home_end(self):
        stdout, rc = self.runner("wrappers/demo_wrapper.sh mainmenu",
                                 [KEY.END, KEY.HOME,
                                  KEY.char("q")],
                                 timeout=8)
        self.assert_exit(0, stdout)
        self.assert_no_shell_errors(stdout)