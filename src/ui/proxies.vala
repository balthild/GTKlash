using Gtk;
using Gee;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/ui/proxies.ui")]
    public class Proxies : Box, Content {
        public string sidebar_row_text { get; default = "Proxies"; }

        Soup.Session session = new Soup.Session();

        ProxyItem? active_proxy_item = null;

        ProxyEditDialog edit_dialog = new ProxyEditDialog();

        [GtkChild] ListBox proxy_list;

        [GtkChild] Button remove_btn;
        [GtkChild] Button edit_btn;
        [GtkChild] Button activate_btn;

        ProxyItem? editing = null;

        construct {
            proxy_list.set_header_func(list_separator_func);
            init_proxy_list();
            edit_dialog.save_proxy.connect(save_proxy);
        }

        void init_proxy_list() {
            LinkedList<ProxyGroup> groups = Vars.config.proxy_groups;
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

        private async void set_active_proxy(string name) {
            Vars.config.active_proxy = name;
            save_config();

            string json = """{"name": "%s"}""".printf(name);
            yield api_call(session, "PUT", "/proxies/Proxy", json);
            yield api_call(session, "PUT", "/proxies/GLOBAL", json);
        }

        [GtkCallback]
        private async void activate_btn_clicked(Button btn) {
            ProxyItem selected = proxy_list.get_selected_row() as ProxyItem;
            if (selected == null || selected == active_proxy_item)
                return;

            string name = selected.get_name();
            yield set_active_proxy(name);

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
            editing = null;
            edit_dialog.show_new();
        }

        [GtkCallback]
        private void remove_proxy(Button btn) {
            ProxyItem selected = proxy_list.get_selected_row() as ProxyItem;
            if (selected == null)
                return;

            proxy_list.remove(selected);

            if (selected.is_group) {
                ProxyGroup group = selected.get_group();
                Vars.config.proxy_groups.remove(group);
            } else {
                Proxy proxy = selected.get_proxy();
                Vars.config.proxies.remove(proxy);
            }

            string name = selected.get_name();
            foreach (ProxyGroup group in Vars.config.proxy_groups) {
                group.proxies.remove(name);
            }

            if (name == Vars.config.active_proxy) {
                var i = Vars.config.proxy_groups.size;
                active_proxy_item = proxy_list.get_row_at_index(i) as ProxyItem;
                active_proxy_item.set_active(true);

                save_config();

                clash_reload_config();
                set_active_proxy.begin(active_proxy_item.get_name());
            } else {
                save_config();
            }
        }

        [GtkCallback]
        private void edit_proxy(Button btn) {
            ProxyItem selected = proxy_list.get_selected_row() as ProxyItem;
            if (selected == null)
                return;

            editing = selected;

            if (selected.is_group)
                edit_dialog.show_group(selected.get_group());
            else
                edit_dialog.show_proxy(selected.get_proxy());
        }

        void save_proxy(Proxy? proxy, ProxyGroup? group) {
            if (editing == null) {
                add_new_proxy(proxy, group);
                return;
            }

            if (editing.is_group) {
                ProxyGroup old = editing.get_group();

                int i = Vars.config.proxy_groups.index_of(old);
                Vars.config.proxy_groups[i] = group;

                editing.set_group(group);
            } else {
                Proxy old = editing.get_proxy();

                int i = Vars.config.proxies.index_of(old);
                Vars.config.proxies[i] = proxy;

                editing.set_proxy(proxy);
            }

            save_config();
            editing = null;
        }

        void add_new_proxy(Proxy? proxy, ProxyGroup? group) {
            if (proxy == null) {
                Vars.config.proxy_groups.add(group);

                var row = new ProxyItem.from_group(group);
                proxy_list.insert(row, Vars.config.proxy_groups.size - 1);
                row.show();
            } else {
                Vars.config.proxies.add(proxy);

                var row = new ProxyItem.from_proxy(proxy);
                proxy_list.insert(row, -1);
                row.show();
            }

            save_config();
        }

        public void on_show() {}
        public void on_hide() {}
    }
}
