using Gtk;
using Gee;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/proxies.ui")]
    public class Proxies : Box, Content {
        Soup.Session session = new Soup.Session();

        ProxyItem? active_proxy_item = null;

        ProxyEditDialog edit_dialog = new ProxyEditDialog();

        [GtkChild] ListBox proxy_list;

        [GtkChild] Button add_btn;
        [GtkChild] Button remove_btn;
        [GtkChild] Button edit_btn;
        [GtkChild] Button activate_btn;

        construct {
            proxy_list.set_header_func(list_separator_func);
            init_proxy_list();
        }

        void init_proxy_list() {
            LinkedList<ProxyGroup?> groups = Vars.config.proxy_groups;
            foreach (ProxyGroup group in groups) {
                var row = new ProxyItem.from_group(group);
                proxy_list.add(row);
                row.show();

                if (group.name == Vars.config.active_proxy) {
                    row.set_active(true);
                    active_proxy_item = row;
                }
            }

            LinkedList<Proxy> proxies = Vars.config.proxies;
            foreach (Proxy proxy in proxies) {
                var row = new ProxyItem.from_proxy(proxy);
                proxy_list.add(row);
                row.show();

                if (proxy.name == Vars.config.active_proxy) {
                    row.set_active(true);
                    active_proxy_item = row;
                }
            }
        }

        [GtkCallback]
        private async void set_active_proxy(Button btn) {
            ProxyItem selected = proxy_list.get_selected_row() as ProxyItem;
            if (selected == null || selected == active_proxy_item)
                return;

            string name = selected.get_name();

            Vars.config.active_proxy = name;
            save_config();

            yield api_call(session, "PUT", "/proxies/Proxy", @"{
                \"name\": \"$name\"
            }");
            yield api_call(session, "PUT", "/proxies/GLOBAL", @"{
                \"name\": \"$name\"
            }");

            active_proxy_item.set_active(false);
            active_proxy_item = selected;
            selected.set_active(true);
        }

        [GtkCallback]
        private void proxy_row_selected(ListBox _, ListBoxRow? row) {
            bool sensitive = row != null;
            remove_btn.set_sensitive(sensitive);
            edit_btn.set_sensitive(sensitive);
            activate_btn.set_sensitive(sensitive);
        }

        [GtkCallback]
        private void add_proxy(Button btn) {
            edit_dialog.show_new();
        }

        // TODO
        [GtkCallback]
        private void remove_proxy(Button btn) {}

        [GtkCallback]
        private void edit_proxy(Button btn) {
            ProxyItem selected = proxy_list.get_selected_row() as ProxyItem;
            if (selected == null)
                return;

            if (selected.is_group) 
                edit_dialog.show_group(selected.get_group());
            else
                edit_dialog.show_proxy(selected.get_proxy());
        }

        public void on_show() {}
        public void on_hide() {}
    }
}
