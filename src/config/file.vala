namespace Gtklash {
    inline string get_config_dir() {
        return Environment.get_user_config_dir() + "/gtklash";
    }

    string read_all(FileInputStream stream) {
        var data_stream = new DataInputStream(stream);
        var data = new StringBuilder();
        string line;
        while ((line = data_stream.read_line(null)) != null) {
            data.append(line);
            data.append("\n");
        }
        return data.str;
    }

    void save_config(bool create = false) {
        File config_file = File.new_for_path(get_config_dir() + "/config.yml");

        FileOutputStream stream;
        if (create) {
            stream = config_file.replace(null, false, FileCreateFlags.NONE);
        } else {
            stream = config_file.create(FileCreateFlags.NONE);
        }

        string data = serialize_config(Vars.config);
        stream.write(data.data);

        // TODO: Generate clash config
    }

    void load_config() {
        File config_file = File.new_for_path(get_config_dir() + "/config.yml");
        FileInputStream stream = config_file.read();

        string data = read_all(stream);
        Vars.config = deserialize_config(data);
    }

    void init_default_config() {
        Vars.config = get_default_config();
        save_config(true);
    }

    void init_config() {
        string config_dir = get_config_dir();

        int status = DirUtils.create_with_parents(config_dir, 0755);
        if (status != 0) {
            // TODO: Show a notification window
            print("Cannot create config directory: %s\n", config_dir);
            Process.exit(-1);
        }

        File config_file = File.new_for_path(config_dir + "/config.yml");
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
}
