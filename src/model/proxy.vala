namespace Gtklash {
    public abstract class Proxy {
        public string name { get; protected set; }
        public string server { get; protected set; }
        public ushort port { get; protected set; }

        public Proxy(string name, string server, ushort port) {
            this.name = name;
            this.server = server;
            this.port = port;
        }

        public abstract string get_proxy_type();

        public Json.Object serialize() {
            var obj = new Json.Object();

            obj.set_string_member("type", get_proxy_type());
            obj.set_string_member("name", name);
            obj.set_string_member("server", server);
            obj.set_int_member("port", port);

            return obj;
        }

        public Proxy.deserialize(Json.Object obj) {
            name = obj.get_string_member("name");
            server = obj.get_string_member("server");
            port = (ushort) obj.get_int_member("port");
        }
    }
}
