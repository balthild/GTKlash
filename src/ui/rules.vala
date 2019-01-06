using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/ui/rules.ui")]
    public class Rules : Box, Content {
        private static SourceLanguageManager lang_manager;
        private static SourceStyleSchemeManager scheme_manager;

        static construct {
            lang_manager = SourceLanguageManager.get_default();
            scheme_manager = SourceStyleSchemeManager.get_default();

            string[] old_lang_paths = lang_manager.get_search_path();
            string[] new_lang_paths = {};
            foreach (var path in old_lang_paths) {
                new_lang_paths += path;
            }

            string[] data_dirs = Environment.get_system_data_dirs();
            foreach (var data_dir in data_dirs) {
                string path = data_dir + "/gtklash/gtksourceview-4";
                scheme_manager.append_search_path(path);
                new_lang_paths += path;
            }

            string data_dir = Environment.get_user_data_dir();
            string path = data_dir + "/gtklash/gtksourceview-4";
            scheme_manager.append_search_path(path);
            new_lang_paths += path;

            lang_manager.set_search_path(new_lang_paths);
        }

        [GtkChild] SourceView editor;

        construct {
            var font = Pango.FontDescription.from_string(get_mono_font());
            // TODO: Deprecated method, use css instead
            // e.g. Gtk.CssProvider.load_from_data("...");
            editor.override_font(font);

            var scheme = scheme_manager.get_scheme("clashrule-light");
            var lang = lang_manager.get_language("clashrule");

            weak SourceBuffer buffer = editor.get_buffer() as SourceBuffer;
            buffer.undo_manager.begin_not_undoable_action();
            buffer.style_scheme = scheme;
            buffer.language = lang;
            buffer.highlight_syntax = true;
            buffer.text = Vars.config.rules;
            buffer.undo_manager.end_not_undoable_action();
        }

        public void on_show() {}
        public void on_hide() {}
    }
}
