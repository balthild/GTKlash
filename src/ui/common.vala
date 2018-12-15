using Gtk;

namespace Gtklash.UI {
    void list_separator_func(ListBoxRow row, ListBoxRow? before) {
        if (before == null) {
            row.set_header(null);
            return;
        }

        Widget header = row.get_header();
        if (header == null) {
            header = new Separator(Orientation.HORIZONTAL);
            header.show();
            row.set_header(header);
        }
    }
}
