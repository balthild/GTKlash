namespace Gtklash {
    public class Vmess : Proxy {
        public override string get_proxy_type() { return "vmess"; }

        public string uuid { get; protected set; }
        public uint alter_id { get; protected set; }
        public string cipher { get; protected set; }

        public bool tls { get; protected set; }
        public bool skip_cert_verify { get; protected set; }

        public string? network { get; protected set; }
        public string? ws_path { get; protected set; }

        public Vmess(
            string name,
            string server,
            ushort port,
            string uuid,
            ushort alter_id,
            string cipher,
            bool tls = false,
            bool skip_cert_verify = false,
            string? network = null,
            string? ws_path = null
        ) {
            base(name, server, port);

            this.uuid = uuid;
            this.alter_id = alter_id;
            this.cipher = cipher;

            this.tls = tls;
            this.skip_cert_verify = skip_cert_verify;

            this.network = network;
            this.ws_path = ws_path;
        }

        public Vmess.deserialize(Json.Object obj) {
            base.deserialize(obj);

            this.uuid = obj.get_string_member("uuid");
            // Oh, clash has different naming styles in one config file
            this.alter_id = (uint) obj.get_int_member("alterId");
            this.cipher = obj.get_string_member("cipher");

            if (obj.has_member("tls"))
                this.tls = obj.get_boolean_member("tls");

            if (obj.has_member("skip-cert-verify"))
                this.skip_cert_verify = obj.get_boolean_member("skip-cert-verify");

            if (obj.has_member("network"))
                this.network = obj.get_string_member("network");

            if (obj.has_member("ws-path"))
                this.ws_path = obj.get_string_member("ws-path");
        }

        public override Json.Object serialize() {
            var obj = base.serialize();

            obj.set_string_member("uuid", uuid);
            obj.set_int_member("alterId", alter_id);
            obj.set_string_member("cipher", cipher);

            if (tls) {
                obj.set_boolean_member("tls", tls);
                obj.set_boolean_member("skip-cert-verify", skip_cert_verify);
            }

            if (network != null) {
                obj.set_string_member("network", network);
                obj.set_string_member("ws-path", ws_path);
            }

            return obj;
        }
    }
}
