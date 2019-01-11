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
            string obfs = "",
            string obfs_host = ""
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

            this.obfs = json_member_str(obj, "obfs", "");
            this.obfs_host = json_member_str(obj, "obfs-host", "");
        }

        public override Json.Object serialize() {
            var obj = base.serialize();

            obj.set_string_member("cipher", cipher);
            obj.set_string_member("password", password);

            if (obfs != "") {
                obj.set_string_member("obfs", obfs);
            }

            if (obfs_host != "") {
                obj.set_string_member("obfs-host", obfs_host);
            }

            return obj;
        }
    }
}
