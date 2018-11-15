namespace Gtklash {
    public async void later(uint interval, int priority = GLib.Priority.DEFAULT) {
        GLib.Timeout.add(interval, () => {
            later.callback();
            return false;
        }, priority);
        yield;
    }
}
