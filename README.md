# GTKlash

A proxy client written in GTK+3. Based on [Clash](https://github.com/Dreamacro/clash).

## Build

### Dependencies

- GLib (2.50 or later)
- GTK+ (3.22 or later)
- libgee
- libsoup
- librsvg
- json-glib
- gtksourceview-4
- gnome-icon-theme-symbolic

### Build dependencies

- meson & ninja
- vala
- go (1.11 or later)

### Compile

```bash
git clone https://github.com/balthild/GTKlash.git
cd GTKlash

# If there're some network issue when accessing golang.org
# export https_proxy=http://example.com:80

meson build
ninja -C build
```

### Run

```bash
RULE_SYNTAX_DATA=data/gtksourceview-4 ./build/src/gtklash
```
