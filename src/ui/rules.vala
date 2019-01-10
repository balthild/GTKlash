using Environment;
using Gtk;

namespace Gtklash.UI {
    [GtkTemplate(ui = "/org/gnome/Gtklash/res/ui/rules.ui")]
    public class Rules : Box, Content {
        private static SourceLanguageManager lang_manager;
        private static SourceStyleSchemeManager scheme_manager;

        private static SourceStyleScheme light_scheme;
        private static SourceStyleScheme dark_scheme;

        private static SourceLanguage rule_lang;

        static construct {
            lang_manager = SourceLanguageManager.get_default();
            scheme_manager = SourceStyleSchemeManager.get_default();

            unowned string[] old_lang_paths = lang_manager.get_search_path();
            string[] new_lang_paths = {};
            foreach (var path in old_lang_paths) {
                new_lang_paths += path;
            }

            // System data dirs (/usr/share, /usr/local/share, etc)
            string[] data_dirs = get_system_data_dirs();
            foreach (var data_dir in data_dirs) {
                string path = data_dir + "/gtklash/gtksourceview-4";
                scheme_manager.append_search_path(path);
                new_lang_paths += path;
            }

            // User data dir (~/.local/share)
            string data_dir_u = get_user_data_dir();
            string path_u = data_dir_u + "/gtklash/gtksourceview-4";
            scheme_manager.append_search_path(path_u);
            new_lang_paths += path_u;

            // Custom data dir (specified by DATA_DIR)
            unowned string? data_dir_c = get_variable("RULE_SYNTAX_DATA");
            if (data_dir_c != null && data_dir_c != "") {
                scheme_manager.append_search_path(data_dir_c);
                new_lang_paths += data_dir_c;
            }

            lang_manager.set_search_path(new_lang_paths);

            light_scheme = scheme_manager.get_scheme("clashrule-light");
            dark_scheme = scheme_manager.get_scheme("clashrule-dark");
            rule_lang = lang_manager.get_language("clashrule");
        }

        bool dark = false;

        weak SourceBuffer editor_buffer;

        [GtkChild]
        SourceView editor;

        construct {
            var font = Pango.FontDescription.from_string(get_mono_font());
            // TODO: Deprecated method, use css instead
            // e.g. Gtk.CssProvider.load_from_data("...");
            editor.override_font(font);

            editor_buffer = editor.get_buffer() as SourceBuffer;

            editor_buffer.style_scheme = light_scheme;
            editor_buffer.language = rule_lang;
            editor_buffer.highlight_syntax = true;

            editor_buffer.undo_manager.begin_not_undoable_action();
            editor_buffer.text = Vars.config.rules;
            editor_buffer.undo_manager.end_not_undoable_action();
        }

        public void on_show() {
            if (dark != Vars.config.dark_editor) {
                dark = Vars.config.dark_editor;
                editor_buffer.style_scheme = dark ? dark_scheme : light_scheme;

                StyleContext context = editor.get_style_context();
                context.remove_class(dark ? "editor-light" : "editor-dark");
                context.add_class(dark ? "editor-dark" : "editor-light");
            }
        }

        public void on_hide() {}
    }
}
