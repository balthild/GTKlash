using Gtk;

namespace Gtklash {
    [GtkTemplate(ui = "/org/gnome/Gtklash/window.ui")]
    public class Window : ApplicationWindow {
        Widget[] contents =  {
            new Gtklash.Contents.Overview(),
            new Gtklash.Contents.Overview(),
        };

        [GtkChild]
        Bin content;

        public Window(Gtk.Application app) {
            Object(application: app);
        }

        [GtkCallback]
        private void switch_content(ListBox _, ListBoxRow? row) {
            int n = row.get_index();
            string name = row.name.substring(4);
            print("Row changed: %d, %s\n", n, name);
            content.child = contents[n];
        }
    }
}

