using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/proxy_item.ui")]
    public class ProxyItem : ListBoxRow {
        public bool is_group { get; private set; }

        public Proxy? proxy;
        private ProxyGroup? group;

        [GtkChild] Box proxy_item_box;

        [GtkChild] Label proxy_name;
        [GtkChild] Label proxy_addr;

        VectorIcon active_indicator;

        public ProxyItem.from_proxy(Proxy proxy) {
            this.is_group = false;
            this.proxy = proxy;
            this.group = null;

            proxy_name.set_text(proxy.name);
            proxy_addr.set_text("%s:%hu".printf(proxy.server, proxy.port));
        }

        public ProxyItem.from_group(ProxyGroup group) {
            this.is_group = true;
            this.proxy = null;
            this.group = group;

            proxy_name.set_text(group.name);
            proxy_addr.set_text("Proxy Group");
        }

        construct {
            active_indicator = new VectorIcon("done");
            active_indicator.set_valign(Align.CENTER);
            active_indicator.set_opacity(0.4);
            active_indicator.set_margin_end(16);

            proxy_item_box.add(active_indicator);
        }

        public string get_name() {
            return is_group ? group.name : proxy.name;
        }

        public Proxy get_proxy() {
            return proxy;
        }

        public ProxyGroup get_group() {
            return group;
        }

        public void set_active(bool active) {
            active_indicator.set_visible(active);
        }
    }
}
