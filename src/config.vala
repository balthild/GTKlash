using Gee;

namespace Gtklash {
    inline string get_config_dir() {
        return Environment.get_user_config_dir() + "/gtklash";
    }

    inline string get_config_path() {
        return get_config_dir() + "/gtklash.conf";
    }

    void save_clash_config() {
        string config_dir = get_config_dir() + "/clash";

        int status = DirUtils.create_with_parents(config_dir, 0755);
        if (status != 0) {
            // TODO: Show a notification window
            print("Cannot create clash config directory: %s\n", config_dir);
            Process.exit(-1);
        }

        File config_file = File.new_for_path(config_dir + "/config.yml");
        FileOutputStream stream = config_file.replace(null, false, FileCreateFlags.NONE);

        string data = Vars.config.generate_clash_config();
        stream.write(data.data);
    }

    void save_config() {
        File config_file = File.new_for_path(get_config_path());
        FileOutputStream stream = config_file.replace(null, false, FileCreateFlags.NONE);

        string data = Vars.config.serialize();
        stream.write(data.data);

        save_clash_config();
    }

    void load_config() {
        File config_file = File.new_for_path(get_config_path());
        FileInputStream stream = config_file.read();

        string data = read_all(stream);
        Vars.config = Config.deserialize(data);

        save_clash_config();
    }

    void init_default_config() {
        Vars.config = get_default_config();
        save_config();
    }

    void init_config() {
        string config_dir = get_config_dir();

        int status = DirUtils.create_with_parents(config_dir, 0755);
        if (status != 0) {
            // TODO: Show a notification window
            print("Cannot create config directory: %s\n", config_dir);
            Process.exit(-1);
        }

        File config_file = File.new_for_path(get_config_path());
        if (!config_file.query_exists()) {
            init_default_config();
        } else {
            FileInfo info = config_file.query_info(FileAttribute.STANDARD_SIZE, 0);
            if (info.get_size() == 0) {
                init_default_config();
            } else {
                load_config();
            }
        }
    }

    Config get_default_config() {
        string uri = @"resource:///org/gnome/Gtklash/res/default.clashrule";
        File file = File.new_for_uri(uri);
        InputStream stream = file.read();
        string defualt_rules = read_all(stream);

        var config = Config() {
            port = 7890,
            socks_port = 7891,
            allow_lan = false,
            external_controller = "127.0.0.1:9090",
            log_level = "info",
            mode = "Rule",
            active_proxy = "local-socks5",

            proxies = new LinkedList<Proxy>(),
            proxy_groups = new LinkedList<ProxyGroup>(),
            rules = defualt_rules,

            tray_icon = true,
            dark_editor = false,
            hide_on_start = false
        };

        config.proxies.add(new Socks5("local-socks5", "127.0.0.1", 1080));

        return config;
    }

    string rule_line_trim_comment(string line) {
        if (line == "")
            return "";

        return line.split("#", 2)[0].strip();
    }

    string? check_rule_valid(string rule, bool strict = false) {
        string[] parts = rule.split(",");
        var length = parts.length;

        unowned string type;
        if (length == 3 || length == 2) {
            type = parts[0]._strip();
        } else {
            return "Syntax error.";
        }

        switch (type) {
            case "DOMAIN":
            case "DOMAIN-SUFFIX":
            case "DOMAIN-KEYWORD":
            case "IP-CIDR":
            case "IP-CIDR6":
            case "GEOIP":
                if (length == 2)
                    return @"Missing parameter for $type rule.";
                else
                    return null;

            case "MATCH":
                if (strict && length == 3)
                    return "Please remove the redundant comma after MATCH.";
                else
                    return null;

            case "FINAL":
                if (strict)
                    return "FINAL has been deprecated. Use MATCH instead.";
                else
                    return null;

            default:
                return "Unknown rule type.";
        }
    }
}
