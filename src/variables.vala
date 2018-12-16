namespace Gtklash {
    public enum Status {
        LOADING, SUCCEEDED, FAILED
    }

    public class Vars {
        public static Config config;
        public static Status clash_status = Status.LOADING;
        public static string clash_error_info = "";

        public static Gtk.Application app;
    }
}
