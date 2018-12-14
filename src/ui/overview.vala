using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/overview.ui")]
    public class Overview : Box, Content {
        Soup.Session session = new Soup.Session();

        [GtkChild] Label status_label;
        [GtkChild] Label http_info_label;
        [GtkChild] Label socks_info_label;
        [GtkChild] Label lan_info_label;
        [GtkChild] Label error_info_label;

        Soup.Session traffic_session = new Soup.Session();

        [GtkChild] Label traffic_up_label;
        [GtkChild] Label traffic_down_label;

        public Overview() {
            update_traffic_daemon.begin();
        }

        async void update_traffic_daemon() {
            while (true) {
                yield later(1000);

                if (!visible || Vars.clash_status != SUCCEEDED)
                    continue;

                string uri = "http://%s/traffic".printf(Vars.config.external_controller);
                Soup.Request request = traffic_session.request_http("GET", uri);

                InputStream stream = yield request.send_async(null);
            	DataInputStream data_stream = new DataInputStream(stream);

            	string line;
            	while ((line = yield data_stream.read_line_async()) != null) {
                    var obj = parse_json_object(line);

                    int64 up = obj.get_int_member("up");
                    int64 down = obj.get_int_member("down");

            		Idle.add(() => {
                        traffic_up_label.set_text(format_traffic(up));
                        traffic_down_label.set_text(format_traffic(down));

                        return Source.REMOVE;
                    });
            	}
            }
        }

        async void check_clash() {
            while (Vars.clash_status == Status.LOADING) {
                yield later(500);
            }

            if (Vars.clash_status == Status.SUCCEEDED) {
                yield update_info();
            }
        }

        void update_status() {
            string status_text;
            switch (Vars.clash_status) {
                case Status.LOADING: status_text = "Starting..."; break;
                case Status.SUCCEEDED: status_text = "Running"; break;
                case Status.FAILED: status_text = "Error"; break;
                default: assert_not_reached();
            }
            status_label.set_text(status_text);

            bool show_detail = Vars.clash_status == Status.SUCCEEDED;
            http_info_label.set_visible(show_detail);
            socks_info_label.set_visible(show_detail);
            lan_info_label.set_visible(show_detail);

            error_info_label.set_text(Vars.clash_error_info);
            error_info_label.set_visible(Vars.clash_status == Status.FAILED);
        }

        async void update_info() {
            var message = new Soup.Message(
                "GET",
                "http://%s/configs".printf(Vars.config.external_controller)
            );
            session.queue_message(message, (session, message) => {
                update_info.callback();
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
                http_status = "HTTP(S) Proxy: <span foreground='#c00'>Failed to listen on port %hu</span>"
                    .printf(Vars.config.port);
            } else {
                http_status = "HTTP(S) Proxy: Listening on port <b>%llu</b>"
                    .printf(http_port);
            }

            int64 socks_port = obj.get_int_member("socket-port");
            string socks_status;
            if (http_port == 0) {
                socks_status = "SOCKS5 Proxy: <span foreground='#c00'>Failed to listen on port %hu</span>"
                    .printf(Vars.config.socks_port);
            } else {
                socks_status = "SOCKS5 Proxy: Listening on port <b>%llu</b>"
                    .printf(socks_port);
            }

            bool allow_lan = obj.get_boolean_member("allow-lan");
            string lan_status = "Allow connecting from LAN: <b>%s</b>"
                .printf(allow_lan ? "Yes" : "No");

            Idle.add(() => {
                http_info_label.set_markup(http_status);
                socks_info_label.set_markup(socks_status);
                lan_info_label.set_markup(lan_status);

                update_status();

                return Source.REMOVE;
            });
        }

        public void on_show() {
            update_status();
            check_clash.begin();
            // TODO: Traffic rate
        }

        public void on_hide() {}
    }
}
