project('libclash', 'c')

go = find_program('go')
cc = meson.get_compiler('c')

if run_command('[', '-f', 'clash.a', ']').returncode() == 0
  message('Found an existing clash.a, skip building libclash.')
else
  message('Building Clash into static library')

  r = run_command(go, 'build',
    '-buildmode=c-archive',
    '-o=clash.a',
    'clash.go',
  )
  assert(r.returncode() == 0, r.stderr())
endif

libclash_obj = declare_dependency(
  dependencies: [
    cc.find_library('pthread'),
    cc.find_library('clash', dirs: meson.current_source_dir()),
  ],
)
