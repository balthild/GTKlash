using Gtk;
using Gee;

namespace Gtklash.UI {
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
        string current_name = "";

        public signal void save_proxy(Proxy? proxy, ProxyGroup? group);

        [GtkChild] Box type_radios_box;
        [GtkChild] RadioButton type_group;

        [GtkChild] Grid proxy_fields;
        [GtkChild] Grid group_fields;

        // Proxy fields
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

        // Group fields
        [GtkChild] RadioButton group_type_url_test;
        [GtkChild] RadioButton group_type_fallback;

        [GtkChild] Entry group_name;
        [GtkChild] Entry group_test_url;
        [GtkChild] SpinButton group_test_interval;

        [GtkChild] ScrolledWindow group_proxies_scroll;
        [GtkChild] ListBox group_proxies;

        public ProxyEditDialog() {
            Object(use_header_bar: 1);
        }

        construct {
            set_modal(true);
            change_visible_fields("ss");

            group_proxies.set_header_func(list_separator_func);
            group_proxies.row_activated.connect((row) => {
                ((GroupProxyRow) row).flip_checked();
            });
        }

        public void show_proxy(Proxy proxy) {
            is_group = false;
            current_name = proxy.name;

            reset_fields();
            type_radios_box.set_visible(false);

            string type = proxy.get_proxy_type();
            change_visible_fields(type);
            switch (type) {
                case "vmess": proxy_type_vmess.set_active(true); break;
                case "http": proxy_type_http.set_active(true); break;
                case "socks5": proxy_type_socks5.set_active(true); break;
                default: proxy_type_ss.set_active(true); break;
            }

            proxy_name.text = proxy.name;
            proxy_server.text = proxy.server;
            proxy_port.value = (double) proxy.port;

            if (proxy is Shadowsocks) {
                weak Shadowsocks ss = (Shadowsocks) proxy;
                proxy_ss_cipher.active_id = ss.cipher;
                proxy_ss_password.text = ss.password;
                proxy_ss_obfs_tls.active = ss.obfs == "tls";
                proxy_ss_obfs_host.text = ss.obfs_host;
            } else if (proxy is Vmess) {
                weak Vmess vmess = (Vmess) proxy;
                proxy_vmess_uuid.text = vmess.uuid;
                proxy_vmess_alter_id.value = (double) vmess.alter_id;
                proxy_vmess_cipher.active_id = vmess.cipher;
                proxy_vmess_tls.active = vmess.tls;
                proxy_vmess_skip_cert_verify.active = vmess.skip_cert_verify;
                proxy_vmess_ws.active = vmess.network == "ws";
                proxy_vmess_ws_path.text = vmess.ws_path;
            } else if (proxy is Socks5) {
                weak Socks5 socks5 = (Socks5) proxy;
                proxy_socks5_username.text = socks5.username;
                proxy_socks5_password.text = socks5.password;
                proxy_socks5_tls.active = socks5.tls;
                proxy_socks5_skip_cert_verify.active = socks5.skip_cert_verify;
            } else if (proxy is HTTP) {
                weak HTTP http = (HTTP) proxy;
                // They use the same fields.
                proxy_socks5_username.text = http.username;
                proxy_socks5_password.text = http.password;
                proxy_socks5_tls.active = http.tls;
                proxy_socks5_skip_cert_verify.active = http.skip_cert_verify;
            } else {
                assert_not_reached();
            }

            show();
        }

        public void show_group(ProxyGroup group) {
            is_group = true;
            current_name = group.name;

            reset_fields();
            type_radios_box.set_visible(false);

            if (group.group_type == "fallback")
                group_type_fallback.set_active(true);
            else
                group_type_url_test.set_active(true);

            group_name.text = group.name;
            group_test_url.text = group.url;
            group_test_interval.value = (double) group.interval;

            update_group_proxy_list(group);

            show();
        }

        public void show_new() {
            is_group = type_group.active;
            current_name = "";

            reset_fields();
            type_radios_box.set_visible(true);

            update_group_proxy_list(null);

            show();
        }

        public override void show() {
            set_transient_for(Vars.app.main_window);

            proxy_fields.set_visible(!is_group);
            group_fields.set_visible(is_group);
            group_proxies_scroll.set_visible(is_group);

            base.show();
        }

        private void reset_fields() {
            proxy_name.text = "";
            proxy_server.text = "";
            proxy_port.value = 8388;

            proxy_ss_password.text = "";
            proxy_ss_obfs_tls.active = false;
            proxy_ss_obfs_host.text = "";

            proxy_vmess_uuid.text = "";
            proxy_vmess_alter_id.value = 64;
            proxy_vmess_tls.active = false;
            proxy_vmess_skip_cert_verify.active = false;
            proxy_vmess_ws.active = false;
            proxy_vmess_ws_path.text = "";

            proxy_socks5_username.text = "";
            proxy_socks5_password.text = "";
            proxy_socks5_tls.active = false;
            proxy_socks5_skip_cert_verify.active = false;

            group_name.text = "";
            group_test_url.text = "";
            group_test_interval.value = 300;
        }

        private void update_group_proxy_list(ProxyGroup? group) {
            foreach (Widget widget in group_proxies.get_children())
                group_proxies.remove(widget);

            foreach (Proxy proxy in Vars.config.proxies)
                group_proxies.add(new GroupProxyRow(proxy));

            group_proxies.show_all();

            if (group == null)
                return;

            foreach (Widget widget in group_proxies.get_children()) {
                unowned GroupProxyRow row = (GroupProxyRow) widget;
                if (group.proxies.contains(row.name))
                    row.flip_checked();
            }
        }

        [GtkCallback]
        private void cancel_edit(Button btn) {
            hide();
        }

        [GtkCallback]
        private void submit_edit(Button btn) {
            if (!validate_fields())
                return;

            hide();

            if (is_group)
                save_proxy(null, construct_group_data());
            else
                save_proxy(construct_proxy_data(), null);
        }

        private void prompt(string message) {
            var msg = new MessageDialog(
                this,
                DialogFlags.MODAL,
                MessageType.WARNING,
                ButtonsType.OK,
                message
            );
            msg.response.connect ((response) => {
                msg.destroy();
            });
            msg.show();
        }

        private bool validate_fields() {
            string name;

            if (is_group) {
                name = group_name.text;

                string url = group_test_url.text;
                if (!url.has_prefix("http://") && !url.has_prefix("https://")) {
                    prompt("Invalid testing URL");
                    return false;
                }
            } else {
                name = proxy_name.text;

                if (proxy_server.text == "") {
                    prompt("Server address must not be empty");
                    return false;
                }

                if (proxy_type_ss.active && proxy_ss_password.text == "") {
                    prompt("Password must not be empty");
                    return false;
                } else if (proxy_type_vmess.active && proxy_vmess_uuid.text == "") {
                    prompt("UUID must not be empty");
                    return false;
                }
            }

            if (name == "" || name == "Proxy") {
                prompt("Invalid name");
                return false;
            }
            if (name != current_name && name_existed(name)) {
                prompt("The name has already existed");
                return false;
            }

            return true;
        }

        private bool name_existed(string name) {
            foreach (ProxyGroup group in Vars.config.proxy_groups) {
                if (name == group.name)
                    return true;
            }

            foreach (Proxy proxy in Vars.config.proxies) {
                if (name == proxy.name)
                    return true;
            }

            return false;
        }

        private Proxy construct_proxy_data() {
            if (proxy_type_ss.active) {
                return new Shadowsocks(
                    proxy_name.text,
                    proxy_server.text,
                    (ushort) proxy_port.value,
                    proxy_ss_cipher.active_id,
                    proxy_ss_password.text,
                    proxy_ss_obfs_tls.active ? "tls" : "",
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
                    proxy_vmess_ws.active ? "ws" : "",
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
            string name = group_name.text;
            string type = group_type_fallback.active ? "fallback" : "url-test";
            string url = group_test_url.text;
            ushort interval = (ushort) group_test_interval.value;

            var group = new ProxyGroup(name, type, url, interval);

            foreach (Widget widget in group_proxies.get_children()) {
                unowned GroupProxyRow row = (GroupProxyRow) widget;
                if (row.is_checked())
                   group.proxies.add(row.name);
            }

            return group;
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

            is_group = btn.name == "type_group";
            proxy_fields.set_visible(!is_group);
            group_fields.set_visible(is_group);

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

    class GroupProxyRow : ListBoxRow {
        public string name { get; private set; }

        Box box;
        Label label;
        CheckButton check;

        construct {
            get_style_context().add_class("group-proxy-row");
            set_can_focus(false);

            box = new Box(Gtk.Orientation.HORIZONTAL, 8);
            box.show();

            label = new Label("");
            label.set_halign(Align.START);
            label.set_hexpand(true);
            label.show();

            check = new CheckButton();
            check.show();

            box.add(label);
            box.add(check);
            add(box);
        }

        public GroupProxyRow(Proxy proxy) {
            this.name = proxy.name;

            label.label = "%s (%s)".printf(name, proxy.get_proxy_type_description());
        }

        public bool is_checked() {
            return check.active;
        }

        public void flip_checked() {
            check.active = !check.active;
        }
    }
}
