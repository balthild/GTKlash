using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/ui/overview.ui")]
    public class Overview : Box, Content {
        [GtkChild]
        TextView status_tf;

        Soup.Session session = new Soup.Session();

        public async void update_status() {
            var message = new Soup.Message("GET", "http://localhost:9090/configs");
            session.queue_message(message, (session, message) => {
                Idle.add(() => {
                    var data = (string) message.response_body.data;
                    status_tf.buffer.text = data;

                    return Source.REMOVE;
                });
                update_status.callback();
            });
            yield;
        }

        public void on_active() {
            print("overview active\n");
            update_status();
        }
    }
}
