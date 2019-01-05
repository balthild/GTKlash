namespace Gtklash {
    public class Socks5 : Proxy {
        public override string get_proxy_type() { return "socks5"; }

        public string username { get; protected set; }
        public string password { get; protected set; }
        public bool tls { get; protected set; }
        public bool skip_cert_verify { get; protected set; }

        public Socks5(
            string name,
            string server,
            ushort port,
            string username = "",
            string password = "",
            bool tls = false,
            bool skip_cert_verify = false
        ) {
            base(name, server, port);

            this.username = username;
            this.password = password;
            this.tls = tls;
            this.skip_cert_verify = skip_cert_verify;
        }

        public Socks5.deserialize(Json.Object obj) {
            base.deserialize(obj);

            if (obj.has_member("username"))
                this.username = obj.get_string_member("username");

            if (obj.has_member("password"))
                this.username = obj.get_string_member("password");

            if (obj.has_member("tls"))
                this.tls = obj.get_boolean_member("tls");

            if (obj.has_member("skip-cert-verify"))
                this.skip_cert_verify = obj.get_boolean_member("skip-cert-verify");
        }

        public override Json.Object serialize() {
            var obj = base.serialize();

            if (tls) {
                obj.set_boolean_member("tls", tls);
                obj.set_boolean_member("skip-cert-verify", skip_cert_verify);
            }

            if (username != "")
                obj.set_string_member("username", username);

            if (password != "")
                obj.set_string_member("password", password);

            return obj;
        }
    }
}
