# GTKlash

A proxy client written in GTK+3. Based on [Clash](https://github.com/Dreamacro/clash).

## Notes about the tray icon

GNOME developers has removed the built-in support for status icon because they think it's useless. If you require an icon in GNOME's tray area (normally the top-right corner of your desktop), you could install this shell extension: [AppIndicator Support](https://extensions.gnome.org/extension/615/appindicator-support/).

Other major desktop environments such as Cinnamon, Unity and KDE Plasma support AppIndicator in place.

Note that GTKlash will keep running in the background after you close the window, even though there's no tray icon shown. If you want to exit the program, click the `Exit` button on the interface.

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
# If you didn't install the resource files to system, you should tell the program where they're in
export RULE_SYNTAX_DATA=$PWD/data/gtksourceview-4
export ICON_DIR=$PWD/data

./build/src/gtklash
```
