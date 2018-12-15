using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/proxy_item.ui")]
    public class ProxyItem : ListBoxRow {
        Proxy proxy;

        [GtkChild] Box proxy_item_box;

        [GtkChild] Label proxy_name;
        [GtkChild] Label proxy_addr;

        VectorIcon active_indicator;

        public ProxyItem(Proxy proxy) {
            this.proxy = proxy;

            proxy_name.set_text(proxy.name);
            proxy_addr.set_text("%s:%hu".printf(proxy.server, proxy.port));

            active_indicator = new VectorIcon("done");
            active_indicator.set_valign(Align.CENTER);
            active_indicator.set_opacity(0.4);
            active_indicator.set_margin_end(16);

            proxy_item_box.add(active_indicator);
        }

        public void set_active(bool active) {
            active_indicator.set_visible(active);
        }
    }
}
