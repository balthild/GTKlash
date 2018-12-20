namespace Gtklash {
    public class HTTP : Proxy {
        public override string get_proxy_type() { return "http"; }

        public bool tls { get; protected set; }
        public bool skip_cert_verify { get; protected set; }

        public HTTP(
            string name,
            string server,
            ushort port,
            bool tls = false,
            bool skip_cert_verify = false
        ) {
            base(name, server, port);

            this.tls = tls;
            this.skip_cert_verify = skip_cert_verify;
        }

        public HTTP.deserialize(Json.Object obj) {
            base.deserialize(obj);

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

            return obj;
        }
    }
}
