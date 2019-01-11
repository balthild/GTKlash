namespace Gtklash {
    public class HTTP : Proxy {
        public override string get_proxy_type() { return "http"; }

        public string username { get; protected set; }
        public string password { get; protected set; }
        public bool tls { get; protected set; }
        public bool skip_cert_verify { get; protected set; }

        public HTTP(
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

        public HTTP.deserialize(Json.Object obj) {
            base.deserialize(obj);

            this.username = json_member_str(obj, "username", "");
            this.password = json_member_str(obj, "password", "");

            this.tls = json_member_bool(obj, "tls", false);
            this.skip_cert_verify = json_member_bool(obj, "skip-cert-verify", false);
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

        public override string get_proxy_type_description() {
            return tls ? "HTTPS" : "HTTP";
        }
    }
}
