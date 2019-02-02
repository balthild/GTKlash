using Gee;

namespace Gtklash {
    public struct Config {
        // General
        ushort port;
        ushort socks_port;
        bool allow_lan;
        string external_controller;
        string log_level;
        string mode;
        string active_proxy;

        // Proxy
        LinkedList<Proxy> proxies;
        LinkedList<ProxyGroup> proxy_groups;
        string rules;

        // Misc
        bool tray_icon;
        bool dark_editor;
        bool hide_on_start;

        private Json.Object generate_object() {
            var obj = new Json.Object();

            // General
            obj.set_int_member("port", port);
            obj.set_int_member("socks-port", socks_port);
            obj.set_boolean_member("allow-lan", allow_lan);
            obj.set_string_member("external-controller", external_controller);
            obj.set_string_member("log-level", log_level);
            obj.set_string_member("mode", mode);
            obj.set_string_member("active-proxy", active_proxy);

            // Proxy
            var proxies = new Json.Array();
            foreach (Proxy proxy in this.proxies) {
                proxies.add_object_element(proxy.serialize());
            }
            obj.set_array_member("proxies", proxies);

            var proxy_groups = new Json.Array();
            foreach (ProxyGroup group in this.proxy_groups) {
                proxy_groups.add_object_element(group.serialize());
            }
            obj.set_array_member("proxy-groups", proxy_groups);

            obj.set_string_member("rules", rules);

            // Misc
            obj.set_boolean_member("tray-icon", tray_icon);
            obj.set_boolean_member("dark-editor", dark_editor);
            obj.set_boolean_member("hide-on-start", hide_on_start);

            return obj;
        }

        public string serialize() {
            var data = new StringBuilder();

            /**
             * Why?
             * In short, for consistency.
             * But we do not need an encryption. If someone keeps editing anyway,
             * then the bugs are what they asked for.
             */
            data.append("# WARNING: DO NOT EDIT THIS FILE AT YOUR OWN!\n");

            var obj = generate_object();
            var node = new Json.Node(Json.NodeType.OBJECT);
            node.set_object(obj);

            Json.Generator generator = new Json.Generator();
            generator.set_root(node);

            data.append(generator.to_data(null));

            return data.str;
        }

        public static Config deserialize(string data) {
            string json_data = data.split("\n")[1];

            Json.Parser parser = new Json.Parser();
            parser.load_from_data(json_data);

            Json.Node node = parser.get_root();
            unowned Json.Object obj = node.get_object();

            Config default = get_default_config();

            var config = Config() {
                // General
                port = (ushort) json_member_int(obj, "port", default.port),
                socks_port = (ushort) json_member_int(obj, "socks-port", default.socks_port),
                allow_lan = json_member_bool(obj, "allow-lan", default.allow_lan),
                external_controller = json_member_str(obj, "external-controller", default.external_controller),
                log_level = json_member_str(obj, "log-level", default.log_level),
                mode = json_member_str(obj, "mode", default.mode),
                active_proxy = json_member_str(obj, "active-proxy", ""),

                // Proxy
                proxies = new LinkedList<Proxy>(),
                proxy_groups = new LinkedList<ProxyGroup>(),
                rules = json_member_str(obj, "rules", default.rules),

                // Misc
                tray_icon = json_member_bool(obj, "tray-icon", default.tray_icon),
                dark_editor = json_member_bool(obj, "dark-editor", default.dark_editor),
                hide_on_start = json_member_bool(obj, "hide-on-start", default.hide_on_start)
            };

            Json.Array proxies = obj.get_array_member("proxies");
            foreach (weak Json.Node proxy_node in proxies.get_elements()) {
                Json.Object proxy_obj = proxy_node.get_object();
                string type = proxy_obj.get_string_member("type");
                Proxy proxy;
                switch (type) {
                    case "ss": proxy = new Shadowsocks.deserialize(proxy_obj); break;
                    case "socks5": proxy = new Socks5.deserialize(proxy_obj); break;
                    case "vmess": proxy = new Vmess.deserialize(proxy_obj); break;
                    case "http": proxy = new HTTP.deserialize(proxy_obj); break;
                    default: assert_not_reached();
                }
                config.proxies.add(proxy);
            }

            Json.Array proxy_groups = obj.get_array_member("proxy-groups");
            foreach (weak Json.Node group_node in proxy_groups.get_elements()) {
                Json.Object group_obj = group_node.get_object();
                ProxyGroup proxy_group = new ProxyGroup.deserialize(group_obj);

                if (proxy_group.name == "Proxy")
                    continue;

                config.proxy_groups.add(proxy_group);
            }

            return config;
        }

        public string generate_clash_config() {
            // Don't worry, YAML is a superset of JSON.
            var obj = new Json.Object();

            obj.set_int_member("port", port);
            obj.set_int_member("socks-port", socks_port);
            obj.set_boolean_member("allow-lan", allow_lan);
            obj.set_string_member("external-controller", external_controller);
            obj.set_string_member("log-level", log_level);
            obj.set_string_member("mode", mode);

            // Proxies
            var proxies = new Json.Array();
            foreach (Proxy proxy in this.proxies) {
                proxies.add_object_element(proxy.serialize());
            }
            obj.set_array_member("Proxy", proxies);

            // Proxy Groups
            var proxy_groups = new Json.Array();
            foreach (ProxyGroup group in this.proxy_groups) {
                if (group.proxies.size > 0)
                    proxy_groups.add_object_element(group.serialize());
            }

            var default_group = new ProxyGroup("Proxy", "select");
            foreach (Proxy proxy in this.proxies) {
                default_group.proxies.add(proxy.name);
            }
            proxy_groups.add_object_element(default_group.serialize());

            obj.set_array_member("Proxy Group", proxy_groups);

            // Rules
            string[] rule_lines = rules.split("\n");
            var clash_rules = new Json.Array();
            foreach (string line in rule_lines) {
                string rule = rule_line_trim_comment(line);
                if (rule == "")
                    continue;

                string? error = check_rule_valid(rule);
                if (error == null)
                    clash_rules.add_string_element(line);
            }
            obj.set_array_member("Rule", clash_rules);

            var node = new Json.Node(Json.NodeType.OBJECT);
            node.set_object(obj);

            Json.Generator generator = new Json.Generator();
            generator.set_root(node);

            return generator.to_data(null);
        }
    }
}
