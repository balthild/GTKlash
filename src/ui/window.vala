using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/ui/window.ui")]
    public class Window : ApplicationWindow {
        Content[] contents = {
            new Gtklash.UI.Overview(),
            new Gtklash.UI.Servers(),
        };

        [GtkChild]
        Bin content;

        public Window(Gtk.Application app) {
            Object(application: app);
        }

        [GtkCallback]
        private void switch_content(ListBox _, ListBoxRow? row) {
            content.foreach((child) => content.remove(child));

            Content widget = contents[row.get_index()];
            content.child = widget;
            widget.on_active();
        }
    }
}
