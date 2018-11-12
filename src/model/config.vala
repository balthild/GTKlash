namespace Gtklash {
    public struct Config {
        ushort port;
        ushort socks_port;
        bool allow_lan;
        string external_controller;
        string log_level;
        string mode;

        Gee.LinkedList<Proxy> proxies;
        Gee.LinkedList<ProxyGroup?> proxy_groups;
        string rules;
    }
}
