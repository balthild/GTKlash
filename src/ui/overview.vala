using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/ui/overview.ui")]
    public class Overview : Box, Content {
        Soup.Session session = new Soup.Session();

        [GtkChild] Label status_label;
        [GtkChild] Label http_status_label;
        [GtkChild] Label socks_status_label;
        [GtkChild] Label lan_status_label;

        async void check_started() {
            while(true) {
                print("check\n");
                yield later(1000);
            }
        }

        async void update_status() {
            var message = new Soup.Message(
                "GET",
                "http://%s/configs".printf(Vars.config.external_controller)
            );
            session.queue_message(message, (session, message) => {
                update_status.callback();
            });
            yield;

            if (message.status_code != Soup.Status.OK) {
                return;
            }

            var data = (string) message.response_body.data;
            var obj = parse_json_object(data);

            int64 http_port = obj.get_int_member("port");
            string http_status;
            if (http_port == 0) {
                http_status = "HTTP(S) Proxy: Failed to listen on port %d"
                    .printf(Vars.config.port);
            } else {
                http_status = "HTTP(S) Proxy: Listening on port <b>%lld</b>"
                    .printf(http_port);
            }

            int64 socks_port = obj.get_int_member("socket-port");
            string socks_status;
            if (http_port == 0) {
                socks_status = "SOCKS5 Proxy: Failed to listen on port %d"
                    .printf(Vars.config.socks_port);
            } else {
                socks_status = "SOCKS5 Proxy: Listening on port <b>%lld</b>"
                    .printf(socks_port);
            }

            bool allow_lan = obj.get_boolean_member("allow-lan");
            string lan_status = "Allow connecting from LAN: <b>%s</b>"
                .printf(allow_lan ? "Yes" : "No");

            Idle.add(() => {
                status_label.set_text("Running");

                http_status_label.set_markup(http_status);
                socks_status_label.set_markup(socks_status);
                lan_status_label.set_markup(lan_status);

                http_status_label.show_now();
                socks_status_label.show_now();
                lan_status_label.show_now();

                return Source.REMOVE;
            });
        }

        public void on_active() {
            // check_started.begin();
            update_status.begin();
        }
    }
}
