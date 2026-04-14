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

libskk_tests = [
  'rom-kana',
  'file-dict',
  'user-dict',
  'cdb-dict',
  'skkserv',
  'rule',
  'context',
  'basic',
]

libskk_file_dict = meson.project_source_root() / 'tests' / 'file-dict.dat'
libskk_cdb_dict = meson.project_source_root() / 'tests' / 'cdb-dict.dat'

tests_c_args = [
  '-DLIBSKK_FILE_DICT="@0@"'.format(libskk_file_dict),
  '-DLIBSKK_CDB_DICT="@0@"'.format(libskk_cdb_dict),
]

foreach name : libskk_tests
  t = executable(name, ['@0@.c'.format(name), 'common.c'],
                 c_args: tests_c_args,
                 dependencies: libskk_dep,
                )
  test(name, t, env: [
    'LIBSKK_DATA_PATH=@0@:@0@/tests'.format(meson.project_source_root()),
  ])
endforeach
