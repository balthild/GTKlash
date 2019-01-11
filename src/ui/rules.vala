using Environment;
using Gtk;

namespace Gtklash.UI {
    struct RuleError {
        int line;
        string text;
        string message;
    }

    class RuleErrorRow : ListBoxRow {
        RuleError error;

        Label label;

        construct {
            get_style_context().add_class("rule-error-row");
            set_can_focus(false);

            label = new Label("");
            label.set_halign(Align.START);
            label.show();

            add(label);
        }

        public void set_error(RuleError error) {
            this.error = error;
            label.set_markup(@"<b>Line $(error.line)</b>: $(error.message)");
        }

        public RuleError get_error() {
            return error;
        }
    }

    [GtkTemplate(ui = "/org/gnome/Gtklash/res/ui/rules.ui")]
    public class Rules : Box, Content {
        public string sidebar_row_text { get; default = "Rules"; }

        private static const int MAX_ERROR_ROWS = 5;

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

            // Custom data dir
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
        bool edited = false;
        bool rule_ok = true;

        Gee.LinkedList<RuleError?> rule_errors;
        TextTag error_tag;

        weak SourceBuffer buffer;

        [GtkChild] SourceView editor;

        [GtkChild] Button undo_btn;
        [GtkChild] Button redo_btn;
        [GtkChild] Button save_btn;

        [GtkChild] Separator error_sep;
        [GtkChild] ListBox error_list;

        construct {
            rule_errors = new Gee.LinkedList<RuleError?>();

            var font = Pango.FontDescription.from_string(get_mono_font());
            // TODO: Deprecated method, use css instead
            // e.g. Gtk.CssProvider.load_from_data("...");
            editor.override_font(font);

            buffer = editor.get_buffer() as SourceBuffer;

            buffer.style_scheme = light_scheme;
            buffer.language = rule_lang;
            buffer.highlight_syntax = true;

            buffer.begin_not_undoable_action();
            buffer.text = Vars.config.rules;
            buffer.end_not_undoable_action();
            buffer.set_modified(false);

            buffer.changed.connect_after(sync_undo_redo_status);
            buffer.undo.connect_after(sync_undo_redo_status);
            buffer.redo.connect_after(sync_undo_redo_status);

            buffer.changed.connect_after(check_rule_valid);
            buffer.modified_changed.connect_after(() => {
                set_edited(buffer.get_modified());
            });

            error_tag = new TextTag("error_tag");
            error_tag.underline = Pango.Underline.ERROR;

            buffer.tag_table.add(error_tag);

            for (int i = 0; i < MAX_ERROR_ROWS; ++i) {
                var row = new RuleErrorRow();
                error_list.add(row);
            }
        }

        private void sync_undo_redo_status() {
            undo_btn.set_sensitive(buffer.can_undo);
            redo_btn.set_sensitive(buffer.can_redo);
        }

        private void check_rule_valid() {
            rule_errors.clear();

            TextIter start, end;
            buffer.get_bounds(out start, out end);
            buffer.remove_tag(error_tag, start, end);

            string rule = buffer.text;
            unowned uint8[] data = rule.data;

            size_t line_start = 0;
            int line_num = 0, error_count = 0;

            // Strings in GLib are null-terminated, same as those in vanilla C.
            // But the length of str.data doesn't cover the trailing zero.
            // The array access is safe, since str.data gives us a reference.
            for (size_t i = 0; i <= data.length; ++i) {
                if (data[i] != '\n' && data[i] != '\0')
                    continue;

                // Copy as needed
                owned uint8[] line_data = data[line_start:i+1];
                line_data[i-line_start] = 0;

                string line = (string) line_data;
                string? error = check_rule_line_valid(line, true);
                if (error != null) {
                    ++error_count;
                    rule_errors.add({ line_num + 1, line, error });

                    buffer.get_iter_at_line(out start, line_num);

                    end = start;
                    end.forward_to_line_end();

                    buffer.apply_tag(error_tag, start, end);
                }

                if (error_count == MAX_ERROR_ROWS) {
                    break;
                }

                ++line_num;
                line_start = i + 1;
            }

            update_error_list();
            set_rule_ok(rule_errors.is_empty);
        }

        private void update_error_list() {
            if (rule_errors.is_empty) {
                error_sep.hide();
                error_list.hide();
                return;
            }

            List<weak Widget> rows = error_list.get_children();
            weak List<weak Widget> iter = rows.first();

            foreach (RuleError error in rule_errors) {
                var row = iter.data as RuleErrorRow;
                row.set_error(error);
                row.show();

                iter = iter.next;
                if (iter == null) {
                    break;
                }
            }

            while (iter != null) {
                (iter.data as Widget).hide();
                iter = iter.next;
            }

            error_sep.show();
            error_list.show();
        }

        private void set_edited(bool flag) {
            edited = flag;
            save_btn.set_sensitive(edited && rule_ok);
        }

        private void set_rule_ok(bool flag) {
            rule_ok = flag;
            save_btn.set_sensitive(edited && rule_ok);
        }

        [GtkCallback]
        private void jump_to_error(ListBoxRow row) {
            RuleError error = (row as RuleErrorRow).get_error();

            TextIter iter;
            buffer.get_iter_at_line(out iter, error.line - 1);

            string[] pieces = error.text.split("#", 2);
            if (pieces.length == 2)
                iter.forward_chars(pieces[0]._chomp().length);
            else
                iter.forward_to_line_end();

            buffer.place_cursor(iter);
        }

        [GtkCallback]
        private void undo_btn_clicked(Button btn) {
            buffer.undo();
        }

        [GtkCallback]
        private void redo_btn_clicked(Button btn) {
            buffer.redo();
        }

        [GtkCallback]
        private void save_btn_clicked(Button btn) {
            buffer.set_modified(false);
        }

        public void on_show() {
            if (dark != Vars.config.dark_editor) {
                dark = Vars.config.dark_editor;
                buffer.style_scheme = dark ? dark_scheme : light_scheme;

                StyleContext context = editor.get_style_context();
                context.remove_class(dark ? "editor-light" : "editor-dark");
                context.add_class(dark ? "editor-dark" : "editor-light");
            }
        }

        public void on_hide() {}
    }
}
