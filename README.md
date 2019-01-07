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

- Meson & Ninja
- Go

### Compile

```bash
git clone https://github.com/balthild/GTKlash.git
cd GTKlash
meson build
ninja -C build
```

### Install data files

Syntax highlighting for rule editor won't work without them.

```bash
mkdir -p $HOME/.local/share/gtklash/gtksourceview-4/
cp -f data/clashrule.lang $HOME/.local/share/gtklash/gtksourceview-4/
cp -f data/clashrule-light.xml $HOME/.local/share/gtklash/gtksourceview-4/
cp -f data/clashrule-dark.xml $HOME/.local/share/gtklash/gtksourceview-4/
```

### Run

```bash
build/src/gtklash
```
