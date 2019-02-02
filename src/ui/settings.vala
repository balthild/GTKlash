using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/ui/settings.ui")]
    public class Settings : Box, Content {
        public string sidebar_row_text { get; default = "Settings"; }

        // [GtkChild] ListBox proxy_settings_list;
        // [GtkChild] ListBox misc_settings_list;

        [GtkChild] SpinButton http_port;
        [GtkChild] SpinButton socks_port;
        [GtkChild] Entry api_controller;
        [GtkChild] Switch allow_lan;

        [GtkChild] Switch tray_icon;
        [GtkChild] Switch dark_editor;
        [GtkChild] Switch hide_on_start;

        bool changed = false;

        construct {
            // proxy_settings_list.set_header_func(list_separator_func);
            // misc_settings_list.set_header_func(list_separator_func);
        }

        private void load_settings() {
            http_port.value = Vars.config.port;
            socks_port.value = Vars.config.socks_port;
            api_controller.text = Vars.config.external_controller;
            allow_lan.state = Vars.config.allow_lan;

            tray_icon.state = Vars.config.tray_icon;
            dark_editor.state = Vars.config.dark_editor;
            hide_on_start.state = Vars.config.hide_on_start;

            changed = false;
        }

        private void save_settings() {
            Vars.config.port = (ushort) http_port.value;
            Vars.config.socks_port = (ushort) socks_port.value;
            Vars.config.external_controller = api_controller.text;
            Vars.config.allow_lan = allow_lan.state;

            Vars.config.tray_icon = tray_icon.state;
            Vars.config.dark_editor = dark_editor.state;
            Vars.config.hide_on_start = hide_on_start.state;

            if (changed) {
                save_config();
                clash_reload_config();
                changed = false;
            }
        }

        [GtkCallback]
        private void input_changed(Editable input) {
            changed = true;
        }

        [GtkCallback]
        private bool switch_toggled(Switch switcher, bool state) {
            switcher.set_state(state);

            if (switcher == allow_lan)
                changed = true;

            if (switcher == tray_icon) {
                Vars.app.set_indicator_visible(state);
            }

            save_settings();
            return true;
        }

        public void on_show() {
            load_settings();
        }

        public void on_hide() {
            if (changed)
                save_settings();
        }
    }
}
