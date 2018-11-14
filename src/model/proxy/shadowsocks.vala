namespace Gtklash {
    public class Shadowsocks : Proxy {
        public override string get_proxy_type() { return "ss"; }

        public string cipher { get; protected set; }
        public string password { get; protected set; }

        public string? obfs { get; protected set; }
        public string? obfs_host { get; protected set; }

        public Shadowsocks(
            string name,
            string server,
            ushort port,
            string cipher,
            string password,
            string? obfs = null,
            string? obfs_host = null
        ) {
            base(name, server, port);

            this.cipher = cipher;
            this.password = password;

            this.obfs = obfs;
            this.obfs_host = obfs_host;
        }

        public Shadowsocks.deserialize(Json.Object obj) {
            base.deserialize(obj);

            this.cipher = obj.get_string_member("cipher");
            this.password = obj.get_string_member("password");

            if (obj.has_member("obfs"))
                this.obfs = obj.get_string_member("obfs");

            if (obj.has_member("obfs-host"))
                this.obfs_host = obj.get_string_member("obfs-host");
        }

        public override Json.Object serialize() {
            var obj = base.serialize();

            obj.set_string_member("cipher", cipher);
            obj.set_string_member("password", password);

            if (obfs != null) {
                obj.set_string_member("obfs", obfs);
                obj.set_string_member("obfs-host", obfs_host);
            }

            return obj;
        }
    }
}
