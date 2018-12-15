using Gtk;

namespace Gtklash.UI {
    public class VectorIcon : DrawingArea {
        string icon;
        int size;

        Gdk.RGBA? cached_color = null;
        Rsvg.Handle? cached_svg = null;

        public VectorIcon(string icon, int size = 24) {
            this.icon = icon;
            this.size = size;

            set_size_request(size, size);
        }

        public override bool draw(Cairo.Context ctx) {
            Gdk.RGBA color = get_style_context().get_color(StateFlags.NORMAL);

            if (cached_svg != null && color.equal(cached_color)) {
                return cached_svg.render_cairo(ctx);
            }

            string uri = @"resource:///org/gnome/Gtklash/res/img/icon_$icon.svg";
            File file = File.new_for_uri(uri);
            InputStream stream = file.read();

            string svg = read_all(stream)
                .replace("${fill}", color.to_string());

            cached_svg = new Rsvg.Handle.from_data(svg.data);
            cached_color = color;

            return cached_svg.render_cairo(ctx);
        }
    }
}
