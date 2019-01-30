extern string clash_hub_parse();

namespace Gtklash {
    void clash_reload() {
        string result = clash_hub_parse();
        if (result == "success") {
            Vars.clash_status = Status.SUCCEEDED;
        } else {
            Vars.clash_status = Status.FAILED;
            Vars.clash_error_info = result;
        }
    }

    void clash_reload_config() {
        print("Reloading clash config\n");
        clash_reload();
    }
}
