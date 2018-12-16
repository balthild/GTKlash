using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/window.ui")]
    public class Window : ApplicationWindow {
        Content[] contents = {
            new Gtklash.UI.Overview(),
            new Gtklash.UI.Proxies(),
        };

        int active = 0;

        [GtkChild]
        Box content;

        public Window(Gtk.Application app) {
            Object(application: app);
        }

        construct {
            delete_event.connect(hide_on_delete);

            foreach (Content widget in contents)
                widget.expand = true;

            Content widget = contents[active];
            content.add(widget);
            widget.on_show();
        }

        public void real_close() {
            delete_event.disconnect(hide_on_delete);
            close();
        }

        [GtkCallback]
        private void switch_content(ListBox _, ListBoxRow? row) {
            int new_active = row.get_index();
            if (new_active == active)
                return;

            Content widget = contents[active];
            content.remove(widget);
            widget.on_hide();

            Content new_widget = contents[new_active];
            content.add(new_widget);
            new_widget.on_show();

            active = new_active;
        }
    }
}
