# Copyright (C) 2011-2012 Daiki Ueno <ueno@unixuser.org>
# Copyright (C) 2011-2012 Red Hat, Inc.

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

INCLUDES = -I$(top_srcdir) $(LIBSKK_CFLAGS)

TESTS_ENVIRONMENT =					\
	G_DEBUG=${G_DEBUG:+"${G_DEBUG},"}gc-friendly	\
	G_SLICE=${G_SLICE},always-malloc		\
	LIBSKK_DATA_PATH=$(top_srcdir)
LOG_COMPILER = $(LIBTOOL) --mode=execute $(VALGRIND) $(VALGRIND_OPTS)
TESTS = rom-kana file-dict user-dict cdb-dict skkserv rule context basic
noinst_PROGRAMS = $(TESTS)
noinst_HEADERS = common.h

AM_CPPFLAGS =								\
	-DLIBSKK_FILE_DICT=\"$(top_srcdir)/tests/file-dict.dat\"	\
	-DLIBSKK_CDB_DICT=\"$(top_srcdir)/tests/cdb-dict.dat\"		\
	$(NULL)

rom_kana_SOURCES = rom-kana.c
rom_kana_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

# kana_kan_SOURCES = kana-kan.c
# kana_kan_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

file_dict_SOURCES = file-dict.c
file_dict_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

cdb_dict_SOURCES = cdb-dict.c
cdb_dict_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

skkserv_SOURCES = skkserv.c
skkserv_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

user_dict_SOURCES = user-dict.c common.c
user_dict_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

rule_SOURCES = rule.c common.c
rule_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

context_SOURCES = context.c common.c
context_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

basic_SOURCES = basic.c common.c
basic_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

EXTRA_DIST = file-dict.dat cdb-dict.dat kana-kan.c
CLEANFILES = user-dict.dat valgrind.log.*

-include $(top_srcdir)/git.mk
