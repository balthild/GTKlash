namespace Gtklash {
    async void later(uint interval, int priority = GLib.Priority.DEFAULT) {
        GLib.Timeout.add(interval, () => {
            later.callback();
            return false;
        }, priority);
        yield;
    }

    Json.Object parse_json_object(string data) {
        Json.Parser parser = new Json.Parser();
        parser.load_from_data(data);

        Json.Node node = parser.steal_root();
        Json.Object obj = node.dup_object();

        return obj;
    }
}
