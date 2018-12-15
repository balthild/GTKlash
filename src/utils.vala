namespace Gtklash {
    async void later(uint interval, int priority = GLib.Priority.DEFAULT) {
        GLib.Timeout.add(interval, () => {
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
}
