using Gtk;
using Soup;

namespace Gtklash {
    delegate void BackgroundTaskCallback(double rate, Status status);
    delegate void BackgroundTask(BackgroundTaskCallback callback);

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
                task(set_progress);

                Idle.add(() => {
                    run_progress.callback();
                    return Source.REMOVE;
                });
                return true;
            });
            yield;

            return status == Status.SUCCEEDED;
        }

        public void set_progress(double rate, Status status) {
            progress.set_fraction(rate > 1 ? 1 : rate);
            this.status = status;
        }
    }
}
