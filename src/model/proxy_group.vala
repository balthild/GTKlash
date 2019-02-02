namespace Gtklash {
    public class ProxyGroup {
        public string name { get; private set; }
        public string group_type { get; private set; }
        public Gee.LinkedList<string> proxies { get; private set; }
        public string url { get; private set; }
        public ushort interval { get; private set; }

        public Json.Object serialize() {
            var obj = new Json.Object();

            obj.set_string_member("name", name);
            obj.set_string_member("type", group_type);

            var proxies = new Json.Array();
            foreach (string proxy in this.proxies) {
                proxies.add_string_element(proxy);
            }
            obj.set_array_member("proxies", proxies);

            if (group_type != "select") {
                obj.set_string_member("url", url);
                obj.set_int_member("interval", interval);
            }

            return obj;
        }

        public ProxyGroup(
            string name,
            string type,
            string url = "",
            ushort interval = 300
        ) {
            this.name = name;
            this.group_type = type;
            this.url = url;
            this.interval = interval;

            this.proxies = new Gee.LinkedList<string>();
        }

        public ProxyGroup.deserialize(Json.Object obj) {
            this.name = obj.get_string_member("name");
            this.group_type = obj.get_string_member("type");

            this.proxies = new Gee.LinkedList<string>();

            Json.Array proxies = obj.get_array_member("proxies");
            foreach (weak Json.Node node in proxies.get_elements()) {
                string proxy = node.get_string();
                this.proxies.add(proxy);
            }

            this.url = json_member_str(obj, "url", "");
            this.interval = (ushort) json_member_int(obj, "interval", 300);

            print("%s: url=%s\n", name, url);
        }
    }
}
