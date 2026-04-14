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

skk_sources = [
  'skk.vala',
]

skk_deps = [
  config_dep,
  libskk_dep,
]

skk_vala_flags = [
  '--vapidir', meson.current_source_dir() / '..' / 'libskk',
]

skk_c_flags = [
  '-include', 'config.h',
]

skk = executable('skk',
  skk_sources,
  dependencies: skk_deps,
  c_args: skk_c_flags,
  include_directories: config_h_dir,
  install: true,
)

install_man('skk.1')

if get_option('fep').enabled()
  skkfep_client_sources = ['fep.vala']

  skkfep_client_deps = [
    config_dep,
    libskk_dep,
    libfep_glib_dep,
  ]

  skkfep_client_c_flags = [
    '-include', 'config.h',
  ]

  skkfep_client = executable('skkfep-client',
    skkfep_client_sources,
    dependencies: skkfep_client_deps,
    c_args: skkfep_client_c_flags,
    include_directories: config_h_dir,
    install: true,
    install_dir: libskk_libexecdir,
  )

  fep = find_program('fep')

  custom_target('skkfep',
    input: ['skkfep.in'],
    output: ['skkfep'],
    capture: true,
    command: [
      'sed',
      '-e', 's!@FEP@!@0@!'.format(fep.full_path()),
      '-e', 's!@CLIENT@!@0@!'.format(libskk_libexecdir / 'skkfep-client'),
      '@INPUT@',
    ],
    install: true,
    install_dir: libskk_bindir,
    install_mode: 'rwxr-xr-x',
  )

  install_man('skkfep.1')
endif
