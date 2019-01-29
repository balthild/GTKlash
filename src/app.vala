using AppIndicator;

namespace Gtklash {
    public class App : Gtk.Application {
        bool started = false;

        public UI.Window main_window { get; protected set; }

        private Indicator indicator;
        private Gtk.Menu menu;

        public App() {
            Object(
                application_id: "org.gnome.Gtklash",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void activate() {
            base.activate();

            if (!started) {
                start_clash();
                hold();

                load_css();
                main_window = new UI.Window(this);

                started = true;
            }

            show_window();
            add_indicator();
        }

        private void load_css() {
            Gtk.CssProvider css_provider = new Gtk.CssProvider();
            css_provider.load_from_resource("/org/gnome/Gtklash/res/app.css");
            Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );
        }

        private void add_indicator() {
            indicator = new Indicator(
                "Gtklash",
                "gtklash-tray-symbolic",
                IndicatorCategory.APPLICATION_STATUS
            );

            // Custom icon dir
            unowned string? icon_dir = Environment.get_variable("ICON_DIR");
            if (icon_dir != null && icon_dir != "") {
                indicator.set_icon_theme_path(icon_dir);
            }

            indicator.set_status(IndicatorStatus.ACTIVE);

            menu = new Gtk.Menu();

            var show_item = new Gtk.MenuItem.with_label("Show window");
            show_item.activate.connect(show_window);
            show_item.show();
            menu.append(show_item);

            // TODO: Quick actions such as changing mode and proxy

            var exit_item = new Gtk.MenuItem.with_label("Exit");
            exit_item.show();
            exit_item.activate.connect(exit_app);
            menu.append(exit_item);

            indicator.set_menu(menu);
        }

        public void show_window() {
            var win = get_active_window();
            if (win == null) {
                win = main_window;
            }
            win.present();
        }

        public void exit_app() {
            release();
            main_window.real_close();
        }
    }
}
