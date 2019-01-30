using AppIndicator;

extern void clash_set_config_home_dir(string path);
extern bool clash_mmdb_is_invalid();
extern void clash_start_download_mmdb();
extern string clash_get_download_progress();

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
            start_app.begin();
        }

        private async void start_app() {
            if (!started) {
                hold();

                init_config();
                yield start_clash();

                load_css();
                main_window = new UI.Window(this);

                started = true;
            }

            show_window();
            add_indicator();
        }

        private async void start_clash() {
            clash_set_config_home_dir(get_config_dir() + "/clash");

            if (clash_mmdb_is_invalid()) {
                var dialog = new ProgressDialog(
                    "Downloading MMDB",
                    "GTKlash requires Maxmind GeoLite Database to make GEOIP rules functional."
                );
                dialog.show();

                bool result = yield dialog.run_progress((callback) => {
                    clash_start_download_mmdb();

                    while (true) {
                        string[] progress = clash_get_download_progress().split(",");

                        double rate = double.parse(progress[1]);
                        Status status;
                        switch (progress[0]) {
                            case "0": status = Status.LOADING; break;
                            case "1": status = Status.SUCCEEDED; break;
                            case "2": status = Status.FAILED; break;
                            default: assert_not_reached();
                        }

                        Idle.add(() => {
                            callback(rate, status);
                            return Source.REMOVE;
                        });

                        if (status != Status.LOADING)
                            break;
                    }
                });
                dialog.destroy();

                if (!result) {
                    // TODO: Show message dialog then exit
                }
            }

            clash_reload();
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
