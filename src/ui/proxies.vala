using Gtk;
using Gee;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/proxies.ui")]
    public class Proxies : Box, Content {
        [GtkChild] ListBox proxy_list;

        public Proxies() {
            proxy_list.set_header_func(list_separator_func);
            init_proxy_list();
        }

        void init_proxy_list() {
            LinkedList<Proxy> proxies = Vars.config.proxies;

            foreach (Proxy proxy in proxies) {
                var row = new ProxyItem(proxy);
                proxy_list.add(row);
                row.show();
            }
        }

        public void on_show() {}
        public void on_hide() {}
    }
}
