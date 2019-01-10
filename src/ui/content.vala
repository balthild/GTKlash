namespace Gtklash.UI {
    public interface Content : Gtk.Widget {
        public abstract string get_sidebar_text();

        public abstract void on_show();
        public abstract void on_hide();
    }
}
