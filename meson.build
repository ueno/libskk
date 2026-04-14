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

project('libskk', [ 'vala', 'c' ],
  version: '1.1.1',
  license: 'GPL3-or-later',
  meson_version: '>= 0.57',
)

gnome = import('gnome')
i18n = import('i18n')
pkgconfig = import('pkgconfig')

skk_api_version = '1.0'

current = 0
revision = 0
age = 0

soversion = current - age
skk_lib_version = '@0@.@1@.@2@'.format(soversion, age, revision)

libskk_prefix = get_option('prefix')
libskk_typelibdir = libskk_prefix / get_option('libdir') / 'girepository-1.0'
libskk_bindir = libskk_prefix / get_option('bindir')
libskk_libexecdir = libskk_prefix / get_option('libexecdir')
libskk_datadir = libskk_prefix / get_option('datadir')
libskk_pkgdatadir = libskk_prefix / get_option('datadir') / 'libskk'
libskk_localedir = libskk_prefix / get_option('localedir')
pkg_install_dir = get_option('libdir') / 'pkgconfig'
libskk_headers_install_dir = get_option('includedir') / meson.project_name()

min_glib_version = '2.36'

valac = meson.get_compiler('vala')
cc = meson.get_compiler('c')

gee_dep = dependency('gee-0.8')
gio_dep = dependency('gio-2.0', version: '>=' + min_glib_version)
glib_dep = dependency('glib-2.0', version: '>=' + min_glib_version)
gobject_dep = dependency('gobject-2.0', version: '>=' + min_glib_version)
json_glib_dep = dependency('json-glib-1.0')
posix_dep = valac.find_library('posix')
xkbcommon_dep = dependency('xkbcommon')
config_dep = valac.find_library('config', dirs: meson.current_source_dir() / 'libskk')
g_ir_compiler = find_program('g-ir-compiler')

valadoc = find_program('valadoc', required: get_option('docs'))
libfep_glib_dep = dependency('libfep-glib', version: '>= 0.0.7', required: get_option('fep'))

conf = configuration_data()
conf.set_quoted('PACKAGE_DATA_DIR', libskk_pkgdatadir)
conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('DATADIR', libskk_datadir)
conf.set_quoted('PKGDATADIR', libskk_pkgdatadir)
conf.set_quoted('LOCALEDIR', libskk_localedir)
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

add_project_arguments([
    # Make sure the targets find the internal VAPI
    '--vapidir', meson.project_source_root() / 'libskk',
  ],
  language: 'vala'
)

# Configuration for the pkgconfig files
common_pkgconf_variables = [
  'exec_prefix=${prefix}',
  'bindir=${prefix}' / get_option('bindir'),
  'datarootdir=${prefix}' / get_option('datadir'),
  'datadir=${datarootdir}',
  'vapidir=${datarootdir}' / 'vala' / 'vapi',
]

subdir('libskk')

subdir('tools')

subdir('po')

subdir('tests')

if get_option('docs').enabled()
  subdir('docs')
endif
