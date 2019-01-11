namespace Gtklash.UI {
    public interface Content : Gtk.Widget {
        public abstract string sidebar_row_text { get; }

        public abstract void on_show();
        public abstract void on_hide();
    }
}
