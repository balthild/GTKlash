using Gtk;

namespace Gtklash {
    [GtkTemplate(ui = "/org/gnome/Gtklash/window.ui")]
    public class Window : ApplicationWindow {
        Box[] contents = {
            new Gtklash.Contents.Overview(),
            new Gtklash.Contents.Servers(),
        };

        [GtkChild]
        Bin content;

        public Window(Gtk.Application app) {
            Object(application: app);
        }

        [GtkCallback]
        private void switch_content(ListBox _, ListBoxRow? row) {
            content.foreach((child) => content.remove(child));

            int n = row.get_index();
            content.child = contents[n];
        }
    }
}
