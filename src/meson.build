gtklash_sources = [
  'main.vala',
  'window.vala',
  'contents/overview.vala',
  'contents/servers.vala',
]

gtklash_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
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
