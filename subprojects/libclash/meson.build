project('libclash', 'c')

go = find_program('go')
cc = meson.get_compiler('c')

message('Building Clash into static library')

r = run_command(go, 'build',
  '-buildmode=c-archive',
  '-o=clash.a',
  'clash.go',
)
assert(r.returncode() == 0, r.stderr())

libclash_obj = declare_dependency(
  dependencies: [
    cc.find_library('pthread'),
    cc.find_library('clash', dirs: meson.current_source_dir()),
  ],
)