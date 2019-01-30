using Soup;

namespace Gtklash {
    public enum Status {
        LOADING, SUCCEEDED, FAILED
    }

    async void later(uint interval, int priority = GLib.Priority.DEFAULT) {
        Timeout.add(interval, () => {
            later.callback();
            return false;
        }, priority);
        yield;
    }

    string read_all(InputStream stream) {
        var data_stream = new DataInputStream(stream);
        var data = new StringBuilder();
        string line;
        while ((line = data_stream.read_line(null)) != null) {
            data.append(line);
            data.append("\n");
        }
        return data.str;
    }

    Json.Object parse_json_object(string data) {
        Json.Parser parser = new Json.Parser();
        parser.load_from_data(data);

        Json.Node node = parser.steal_root();
        Json.Object obj = node.dup_object();

        return obj;
    }

    const uint64 KB_BASE = 1024;
    const double MB_BASE = 1048576;
    const double GB_BASE = 1073741824;
    const double TB_BASE = 1099511627776;
    const double PB_BASE = 1125899906842624;

    string format_traffic(uint64 bytes) {
        if (bytes > PB_BASE)
            return "%.1f PiB/s".printf(bytes / PB_BASE);
        else if (bytes > TB_BASE)
            return "%.1f TiB/s".printf(bytes / TB_BASE);
        else if (bytes > GB_BASE)
            return "%.1f GiB/s".printf(bytes / GB_BASE);
        else if (bytes > MB_BASE)
            return "%.1f MiB/s".printf(bytes / MB_BASE);
        else if (bytes > KB_BASE)
            return "%lld KiB/s".printf(bytes / KB_BASE);
        else
            return "%lld Byte/s".printf(bytes);
    }

    async Message api_call(Session session, string method, string uri, string? body = null) {
        string url = "http://%s%s".printf(Vars.config.external_controller, uri);
        var message = new Message(method, url);

        if (body != null) {
            message.set_request("application/json", MemoryUse.COPY, body.data);
        }

        session.queue_message(message, (session, message) => {
            api_call.callback();
        });
        yield;

        return message;
    }

    string get_mono_font() {
        GLib.Settings settings = new GLib.Settings("org.gnome.desktop.interface");
        string font_name = settings.get_string("monospace-font-name");

        if (font_name == "")
            return "Monospace";
        else
            return font_name;
    }

    string json_member_str(unowned Json.Object obj, string name, string default) {
        unowned Json.Node? node = obj.get_member(name);
        return node == null ? default : (node.dup_string() ?? default);
    }

    int64 json_member_int(unowned Json.Object obj, string name, int64 default) {
        unowned Json.Node? node = obj.get_member(name);
        return node == null ? default : node.get_int();
    }

    bool json_member_bool(unowned Json.Object obj, string name, bool default) {
        unowned Json.Node? node = obj.get_member(name);
        return node == null ? default : node.get_boolean();
    }
}
