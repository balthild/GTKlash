using Gtk;
using Gee;

namespace Gtklash {
    private struct FieldRows { int begin; int end; }

    [GtkTemplate(ui = "/org/gnome/Gtklash/res/proxy_edit_dialog.ui")]
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

        public bool is_group = false;
        Proxy? proxy = null;
        ProxyGroup? group = null;

        public signal void save_proxy(Proxy? proxy, ProxyGroup? group);

        [GtkChild] RadioButton type_proxy;
        [GtkChild] RadioButton type_group;

        [GtkChild] Grid proxy_fields;

        [GtkChild] RadioButton proxy_type_ss;
        [GtkChild] RadioButton proxy_type_vmess;
        [GtkChild] RadioButton proxy_type_socks5;
        [GtkChild] RadioButton proxy_type_http;

        [GtkChild] Entry proxy_name;
        [GtkChild] Entry proxy_server;
        [GtkChild] Entry proxy_port;

        [GtkChild] Entry proxy_ss_password;
        [GtkChild] ComboBox proxy_ss_cipher;
        [GtkChild] Switch proxy_ss_obfs_tls;
        [GtkChild] Entry proxy_ss_obfs_host;

        public ProxyEditDialog() {
            Object(use_header_bar: 1);
        }

        construct {
            set_modal(true);
        }

        public void show_proxy(Proxy proxy) {
            this.is_group = false;
            this.group = null;
            this.proxy = proxy;
            show_form();
        }

        public void show_group(ProxyGroup group) {
            this.is_group = true;
            this.proxy = null;
            this.group = group;
            show_form();
        }

        public void show_new() {
            this.is_group = false;
            this.group = null;
            this.proxy = new Shadowsocks(
                "", "", 8388,
                "AEAD_CHACHA20_POLY1305", "",
                null, null
            );
            show_form();
        }

        void show_form() {
            set_transient_for(Vars.app.main_window);

            // TODO: Update fields
            change_visible_fields("ss");

            show();
        }

        [GtkCallback]
        private void cancel_edit(Button btn) {
            hide();
        }

        [GtkCallback]
        private void submit_edit(Button btn) {
            // TODO
            // save_proxy();
            hide();
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