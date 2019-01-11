namespace Gtklash {
    public struct ProxyGroup {
        string name;
        string type;
        Gee.LinkedList<string> proxies;
        string url;
        ushort interval;

        public Json.Object serialize() {
            var obj = new Json.Object();

            obj.set_string_member("name", name);
            obj.set_string_member("type", type);

            var proxies = new Json.Array();
            foreach (string proxy in this.proxies) {
                proxies.add_string_element(proxy);
            }
            obj.set_array_member("proxies", proxies);

            if (url != "") {
                obj.set_string_member("url", url);
                obj.set_int_member("interval", interval);
            }

            return obj;
        }

        public static ProxyGroup deserialize(Json.Object obj) {
            var group = ProxyGroup() {
                name = obj.get_string_member("name"),
                type = obj.get_string_member("type"),
                proxies = new Gee.LinkedList<string>()
            };

            Json.Array proxies = obj.get_array_member("proxies");
            foreach (weak Json.Node node in proxies.get_elements()) {
                string proxy = node.get_string();
                group.proxies.add(proxy);
            }

            group.url = json_member_str(obj, "url", "");
            group.interval = (ushort) json_member_int(obj, "interval", 300);

            return group;
        }
    }
}
