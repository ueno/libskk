# Copyright (C) 2011-2026 Daiki Ueno <ueno@gnu.org>
# Copyright (C) 2011-2026 Red Hat, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

skk_build_dir = meson.current_build_dir()

libskk_gir_name = 'Skk-@0@'.format(skk_api_version)

libskk_sources = files(
  'rom-kana.vala',
  'encoding.vala',
  'dict.vala',
  'file-dict.vala',
  'cdb-dict.vala',
  'user-dict.vala',
  'skkserv.vala',
  'key-event.vala',
  'key-event-filter.vala',
  'keymap.vala',
  'rule.vala',
  'map-file.vala',
  'state.vala',
  'context.vala',
  'candidate.vala',
  'candidate-list.vala',
  'nicola.vala',
  'expr.vala',
  'util.vala',
  'keysyms.vala',
  'completion.vala',
)

libskk_deps = [
  config_dep,
  gobject_dep,
  gio_dep,
  gee_dep,
  json_glib_dep,
  posix_dep,
  xkbcommon_dep,
]

libskk_vala_flags = [
  '--includedir', meson.project_name(),
  '-h', 'libskk-internals.h',
  '--internal-vapi', 'skk-internals-@0@.vapi'.format(skk_api_version),
]

libskk_c_flags = [
  '-include', 'config.h',
  '-DG_LOG_DOMAIN="skk"',
]

libskk_lib = shared_library('skk',
  libskk_sources,
  dependencies: [ libskk_deps ],
  include_directories: config_h_dir,
  vala_args: libskk_vala_flags,
  c_args: libskk_c_flags,
  vala_header: 'libskk.h',
  vala_gir: libskk_gir_name + '.gir',
  version: skk_lib_version,
  install: true,
  install_dir: [ true, libskk_headers_install_dir, true, true ],
)

# Also make sure to install the VAPI's .deps file
install_data('skk-1.0.deps',
  install_dir: get_option('datadir') / 'vala' / 'vapi',
)

custom_target(libskk_gir_name + '.typelib',
  command: [ g_ir_compiler,
    '--output', '@OUTPUT@',
    '--shared-library', 'lib' + libskk_lib.name(),
    meson.current_build_dir() / (libskk_gir_name + '.gir')
  ],
  output: libskk_gir_name + '.typelib',
  depends: libskk_lib,
  install: true,
  install_dir: libskk_typelibdir,
)

libskk_dep = declare_dependency(
  link_with: libskk_lib,
  include_directories: include_directories('.', '..'),
  dependencies: libskk_deps,
)

pkgconfig.generate(libskk_lib,
  name: 'libskk',
  description: 'a library to deal with Japanese kana-to-kanji conversion method',
  requires: [ glib_dep, gobject_dep ],
  requires_private: [ gee_dep ],
  variables: common_pkgconf_variables,
)
