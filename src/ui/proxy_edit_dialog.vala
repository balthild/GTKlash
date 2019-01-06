using Gtk;
using Gee;

namespace Gtklash {
    private struct FieldRows { int begin; int end; }

    [GtkTemplate(ui = "/org/gnome/Gtklash/res/ui/proxy_edit_dialog.ui")]
    class ProxyEditDialog : Dialog {
        static HashMap<string, FieldRows?> proxy_type_rows;
        static HashMultiMap<string, string> field_associations;

        static construct {
            proxy_type_rows = new HashMap<string, FieldRows?>();
            proxy_type_rows["ss"] = { 4, 7 };
            proxy_type_rows["vmess"] = { 8, 14 };
            proxy_type_rows["socks5"] = { 15, 18 };
            proxy_type_rows["http"] = { 15, 18 };

            field_associations = new HashMultiMap<string, string>();
            field_associations["proxy_ss_obfs_tls"] = "proxy_ss_obfs_host";
            field_associations["proxy_vmess_ws"] = "proxy_vmess_ws_path";
            field_associations["proxy_vmess_tls"] = "proxy_vmess_skip_cert_verify";
            field_associations["proxy_socks5_tls"] = "proxy_socks5_skip_cert_verify";
        }

        bool is_group = false;

        public signal void save_proxy(Proxy? proxy, ProxyGroup? group);

        [GtkChild] Box type_radios_box;
        [GtkChild] RadioButton type_proxy;
        [GtkChild] RadioButton type_group;

        [GtkChild] Grid proxy_fields;
        [GtkChild] Grid group_fields;

        [GtkChild] RadioButton proxy_type_ss;
        [GtkChild] RadioButton proxy_type_vmess;
        [GtkChild] RadioButton proxy_type_socks5;
        [GtkChild] RadioButton proxy_type_http;

        [GtkChild] Entry proxy_name;
        [GtkChild] Entry proxy_server;
        [GtkChild] SpinButton proxy_port;

        [GtkChild] Entry proxy_ss_password;
        [GtkChild] ComboBox proxy_ss_cipher;
        [GtkChild] Switch proxy_ss_obfs_tls;
        [GtkChild] Entry proxy_ss_obfs_host;

        [GtkChild] Entry proxy_vmess_uuid;
        [GtkChild] SpinButton proxy_vmess_alter_id;
        [GtkChild] ComboBox proxy_vmess_cipher;
        [GtkChild] Switch proxy_vmess_ws;
        [GtkChild] Entry proxy_vmess_ws_path;
        [GtkChild] Switch proxy_vmess_tls;
        [GtkChild] Switch proxy_vmess_skip_cert_verify;

        [GtkChild] Entry proxy_socks5_username;
        [GtkChild] Entry proxy_socks5_password;
        [GtkChild] Switch proxy_socks5_tls;
        [GtkChild] Switch proxy_socks5_skip_cert_verify;

        public ProxyEditDialog() {
            Object(use_header_bar: 1);
        }

        construct {
            set_modal(true);
            change_visible_fields("ss");
        }

        public void show_proxy(Proxy proxy) {
            is_group = false;
            show_form(false);
        }

        public void show_group(ProxyGroup group) {
            is_group = true;
            show_form(false);
        }

        public void show_new() {
            is_group = false;
            show_form(true);
        }

        void show_form(bool is_new) {
            set_transient_for(Vars.app.main_window);

            // TODO: Update fields
            type_radios_box.set_visible(is_new);

            show();
        }

        [GtkCallback]
        private void cancel_edit(Button btn) {
            hide();
        }

        [GtkCallback]
        private void submit_edit(Button btn) {
            hide();

            if (is_group)
                save_proxy(null, construct_group_data());
            else
                save_proxy(construct_proxy_data(), null);
        }

        private Proxy construct_proxy_data() {
            // TODO: Validate fields

            if (proxy_type_ss.active) {
                return new Shadowsocks(
                    proxy_name.text,
                    proxy_server.text,
                    (ushort) proxy_port.value,
                    proxy_ss_cipher.active_id,
                    proxy_ss_password.text,
                    proxy_ss_obfs_tls.active ? "tls" : null,
                    proxy_ss_obfs_host.text
                );
            } else if (proxy_type_vmess.active) {
                return new Vmess(
                    proxy_name.text,
                    proxy_server.text,
                    (ushort) proxy_port.value,
                    proxy_vmess_uuid.text,
                    (ushort) proxy_vmess_alter_id.value,
                    proxy_vmess_cipher.active_id,
                    proxy_vmess_tls.active,
                    proxy_vmess_skip_cert_verify.active,
                    proxy_vmess_ws.active ? "ws" : null,
                    proxy_vmess_ws_path.text
                );
            } else if (proxy_type_socks5.active) {
                return new Socks5(
                    proxy_name.text,
                    proxy_server.text,
                    (ushort) proxy_port.value,
                    proxy_socks5_username.text,
                    proxy_socks5_password.text,
                    proxy_socks5_tls.active,
                    proxy_socks5_skip_cert_verify.active
                );
            } else if (proxy_type_http.active) {
                return new HTTP(
                    proxy_name.text,
                    proxy_server.text,
                    (ushort) proxy_port.value,
                    proxy_socks5_username.text,
                    proxy_socks5_password.text,
                    proxy_socks5_tls.active,
                    proxy_socks5_skip_cert_verify.active
                );
            } else {
                assert_not_reached();
            }
        }

        private ProxyGroup construct_group_data() {
            // TODO
            return ProxyGroup();
        }

        private void change_visible_fields(string type) {
            FieldRows rows = proxy_type_rows[type];

            foreach (Widget widget in proxy_fields.get_children()) {
                Value ta = Value(typeof(int));
                proxy_fields.child_get_property(widget, "top-attach", ref ta);

                int row = ta.get_int();
                if (row < 4)
                    continue;

                widget.set_visible(row >= rows.begin && row <= rows.end);
            }
        }

        [GtkCallback]
        private void type_toggled(ToggleButton btn) {
            if (!btn.active)
                return;

            // Workaround for the issue that the dialog is positioned
            // incorrectly after it is resized.
            set_visible(false);

            proxy_fields.set_visible(btn.name == "type_proxy");
            group_fields.set_visible(btn.name == "type_group");

            // ...as well.
            set_visible(true);
        }

        [GtkCallback]
        private void proxy_type_toggled(ToggleButton btn) {
            if (!btn.active)
                return;

            // Workaround for the issue that the dialog is positioned
            // incorrectly after it is resized.
            set_visible(false);

            change_visible_fields(btn.name.substring(11));

            // ...as well.
            set_visible(true);
        }

        private void field_association(string trigger, bool sensitive) {
            var associated = field_associations[trigger];

            foreach (Widget widget in proxy_fields.get_children()) {
                if (associated.contains(widget.name)) {
                    widget.set_sensitive(sensitive);
                }
            }
        }

        [GtkCallback]
        private bool field_association_switch(Switch sch, bool state) {
            field_association(sch.name, state);
            return false;
        }
    }
}