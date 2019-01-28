extern string clash_reload();
extern void clash_set_config_home_dir(string path);

namespace Gtklash {
    void start_clash() {
        init_config();
        clash_set_config_home_dir(get_config_dir() + "/clash");

        string result = clash_reload();
        if (result == "success") {
            Vars.clash_status = Status.SUCCEEDED;
        } else {
            Vars.clash_status = Status.FAILED;
            Vars.clash_error_info = result;
        }
    }

    void clash_reload_config() {
        print("Reloading clash config\n");

        string result = clash_reload();
        if (result == "success") {
            Vars.clash_status = Status.SUCCEEDED;
        } else {
            Vars.clash_status = Status.FAILED;
            Vars.clash_error_info = result;
        }
    }
}
