namespace Gtklash {
    public struct ProxyGroup {
        string name;
        string type;
        Gee.LinkedList<string> proxies;
        string? url;
        uint? interval;

        public Json.Object serialize() {
            var obj = new Json.Object();

            obj.set_string_member("name", name);
            obj.set_string_member("type", type);

            var proxy_names = new Json.Array();
            foreach (string proxy in proxies) {
                proxy_names.add_string_element(proxy);
            }
            obj.set_array_member("proxies", proxy_names);

            if (url != null) obj.set_string_member("url", url);
            if (interval != null) obj.set_int_member("interval", interval);

            return obj;
        }

        public bool deserialize(Json.Object obj) {
            // TODO
            return false;
        }
    }
}
