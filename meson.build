project('stremio', 'cpp', version: '4.4.164', default_options: ['cpp_std=c++11'])

qt5 = import('qt5')
src_dir = include_directories('src')
add_project_arguments('-DSTREMIO_SHELL_VERSION="@0@"'.format(meson.project_version()), '-DUNICODE', '-D_UNICODE', language: 'cpp')

sources = [
  'src/main.cpp',
  'src/mpv.cpp',
  'src/stremioprocess.cpp',
  'src/screensaver.cpp',
  'src/systemtray.cpp'
]

sources += qt5.compile_resources(sources : ['src/qml.qrc'])

qtprocessed = qt5.preprocess(moc_headers: ['src/main.h','src/mpv.h','src/screensaver.h','src/stremioprocess.h','src/systemtray.h','src/mpv_qthelper.h'])

dependencies = []

dependencies += dependency('qt5', modules: ['Core', 'Qml', 'Quick', 'Network', 'Widgets', 'WebEngine', 'WebChannel', 'DBus', 'OpenGL','Gui'])
dependencies += dependency('mpv')

if host_machine.system() == 'darwin'
  dependencies += declare_dependency(
    link_args : ['-framework', 'IOKit', '-framework', 'CoreFoundation'],
  )
endif

executable(
  meson.project_name(),
  sources,
  qtprocessed,
  dependencies: dependencies,
  include_directories: [src_dir],
  gui_app: true,
  install: true
)