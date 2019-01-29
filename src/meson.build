gtklash_sources = [
  'main.vala',
  'app.vala',
  'variables.vala',
  'utils.vala',
  'clash.vala',
  'config.vala',

  'ui/common.vala',
  'ui/window.vala',
  'ui/content.vala',
  'ui/overview.vala',
  'ui/proxies.vala',
  'ui/rules.vala',

  'ui/vector_icon.vala',
  'ui/proxy_item.vala',
  'ui/proxy_edit_dialog.vala',

  'model/config.vala',
  'model/proxy.vala',
  'model/proxy_group.vala',
  'model/proxy/shadowsocks.vala',
  'model/proxy/vmess.vala',
  'model/proxy/socks5.vala',
  'model/proxy/http.vala',
]

gtklash_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gtksourceview-4', version: '>= 4.0'),
  dependency('appindicator3-0.1'),
  dependency('librsvg-2.0'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
  dependency('libsoup-2.4', version: '>= 2.47')
]

gnome = import('gnome')

gtklash_sources += gnome.compile_resources('gtklash-resources',
  'gtklash.gresource.xml',
  c_name: 'gtklash',
)

clash = subproject('libclash').get_variable('libclash_obj')
gtklash_deps += clash

executable('gtklash', gtklash_sources,
  vala_args: '--target-glib=2.50',
  dependencies: gtklash_deps,
  install: true,
)
