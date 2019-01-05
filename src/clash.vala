extern string clash_run();
extern string clash_update_all_config();
extern void clash_set_config_home_dir(string path);

namespace Gtklash {
    void start_clash() {
        init_config();
        clash_set_config_home_dir(get_config_dir() + "/clash");

        string result = clash_run();
        if (result == "success") {
            Vars.clash_status = Status.SUCCEEDED;
        } else {
            Vars.clash_status = Status.FAILED;
            Vars.clash_error_info = result;
        }
    }

    void clash_reload_config() {
        string result = clash_update_all_config();
        if (result == "success") {
            Vars.clash_status = Status.SUCCEEDED;
        } else {
            Vars.clash_status = Status.FAILED;
            Vars.clash_error_info = result;
        }
    }
}
