# GTKlash

A proxy client written in GTK+3. Based on [Clash](https://github.com/Dreamacro/clash).

## Build

### Dependencies

- GLib 2.50 or later
- GTK+ 3.22 or later
- libgee
- libsoup
- librsvg
- json-glib
- gtksourceview-4
- gnome-icon-theme-symbolic

### Build dependencies

- meson & ninja
- vala
- go

### Compile

```bash
git clone https://github.com/balthild/GTKlash.git
cd GTKlash
meson build
ninja -C build
```

### Run

```bash
RULE_SYNTAX_DATA=data/gtksourceview-4 ./build/src/gtklash
```
