using AppIndicator;

namespace Gtklash {
    public class App : Gtk.Application {
        bool started = false;

        public UI.Window main_window { get; protected set; }

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
                // add_indicator();
                main_window = new UI.Window(this);

                started = true;
            }

            show_window();
        }

        public void load_css() {
            Gtk.CssProvider css_provider = new Gtk.CssProvider();
            css_provider.load_from_resource("/org/gnome/Gtklash/res/app.css");
            Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );
        }

        public void show_window() {
            var win = get_active_window();
            if (win == null) {
                win = main_window;
            }
            win.present();
        }

        protected void add_indicator() {
            // TODO
            var indicator = new Indicator(
                "Gtklash",
                "Some messages.",
                IndicatorCategory.APPLICATION_STATUS
            );

            indicator.set_status(IndicatorStatus.ACTIVE);
            indicator.set_attention_icon("indicator-messages-new");

            var menu = new Gtk.Menu();

            var item = new Gtk.MenuItem.with_label("Foo");
            item.activate.connect(() => {
                indicator.set_status(IndicatorStatus.ATTENTION);
            });
            item.show();
            menu.append(item);

            var bar = item = new Gtk.MenuItem.with_label("Bar");
            item.show();
            item.activate.connect(() => {
                indicator.set_status(IndicatorStatus.ACTIVE);
            });
            menu.append(item);

            indicator.set_menu(menu);
            indicator.set_secondary_activate_target(bar);
        }
    }
}
