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

int main(string[] args) {
    Gtklash.init_config();

    clash_set_config_home_dir(Gtklash.get_config_dir() + "/clash");
    clash_run();

    var app = new Gtklash.App();
    app.activate.connect(() => {
        var win = app.active_window;
        if (win == null) {
            win = new Gtklash.UI.Window(app);
        }
        win.present();
    });

    return app.run(args);
}
