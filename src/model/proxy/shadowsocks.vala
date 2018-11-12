namespace Gtklash {
    public class Shadowsocks : Proxy {
        public new const string type = "ss";

        public string cipher { get; protected set; }
        public string password { get; protected set; }

        public Shadowsocks(
            string name,
            string server,
            ushort port,
            string cipher,
            string password
        ) {
            base(name, server, port);
            this.cipher = cipher;
            this.password = password;
        }

        public override string get_proxy_type() { return "ss"; }
    }
}
