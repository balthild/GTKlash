using Gtk;
using Soup;

namespace Gtklash {
    delegate void BackgroundTask(ProgressDialog dialog);

    [GtkTemplate(ui = "/org/gnome/Gtklash/res/ui/progress_dialog.ui")]
    class ProgressDialog : Dialog {
        [GtkChild] Label hint_text;
        [GtkChild] ProgressBar progress;

        Status status = Status.LOADING;

        public ProgressDialog(string title, string hint) {
            Object(use_header_bar: 1);

            set_title(title);
            hint_text.set_text(hint);
        }

        public async bool run_progress(BackgroundTask task) {
            new Thread<bool>("progress-dialog-task", () => {
                task(this);
                return true;
            });

            while (true) {
                if (status == Status.LOADING)
                    yield later(200);
                else
                    break;
            }

            return status == Status.SUCCEEDED;
        }

        public void set_progress(double rate, Status status) {
            progress.set_fraction(rate > 1 ? 1 : rate);
            this.status = status;
        }
    }
}
