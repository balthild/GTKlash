namespace Gtklash {
    public class Socks5 : Proxy {
        public Socks5(string name, string server, ushort port) {
            base(name, server, port);
        }

        public override string get_proxy_type() { return "socks5"; }
    }
}
