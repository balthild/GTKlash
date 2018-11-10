/* Gtklash
 *
 * Copyright 2018 Balthild
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

extern string clash_run();
extern string clash_update_all_config();
extern void clash_set_config_home_dir(string path);
extern string clash_test();

int main(string[] args) {
    // Ensure config
    string config_dir = Environment.get_user_config_dir() + "/gtklash";

    File config_file = File.new_for_path(config_dir + "/config.yml");
    if (!config_file.query_exists()) {
        Gtklash.write_default_config(config_file, false);
    } else {
        FileInfo info = config_file.query_info(FileAttribute.STANDARD_SIZE, 0);
        if (info.get_size() == 0) {
            Gtklash.write_default_config(config_file, true);
        }
    }

    int status = DirUtils.create_with_parents(config_dir, 0755);
    if (status != 0) {
        // TODO: Show a notification window
        print("Cannot create config directory: %s\n", config_dir);
        return -1;
    }

    // Start Clash
    clash_set_config_home_dir(config_dir);
    clash_run();

    // Start GUI
    var app = new Gtk.Application("org.gnome.Gtklash", ApplicationFlags.FLAGS_NONE);
    app.activate.connect(() => {
        var win = app.active_window;
        if (win == null) {
            win = new Gtklash.Window(app);
        }
        win.present();
    });

    return app.run(args);
}
