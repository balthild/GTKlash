namespace Gtklash {
    public class App : Gtk.Application {
        public App() {
            Object(
                application_id: "org.gnome.Gtklash",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void activate() {
            base.activate();

            Gtk.CssProvider css_provider = new Gtk.CssProvider();
            css_provider.load_from_resource("/org/gnome/Gtklash/ui/app.css");
            Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );
        }
    }
}
