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

# force include config.h before gi18n.h.
AM_CPPFLAGS = -include $(CONFIG_HEADER)

lib_LTLIBRARIES = libskk.la

libskk_la_VALAFLAGS =						\
	--includedir=libskk					\
	-H libskk.h						\
	--vapi skk-@SKK_API_VERSION@.vapi			\
	-h libskk-internals.h					\
	--vapidir=.						\
	--pkg config						\
	--pkg glib-2.0						\
	--pkg gio-2.0						\
	--pkg gee-0.8						\
	--pkg posix						\
	--pkg json-glib-1.0					\
	--pkg xkbcommon						\
	--internal-vapi skk-internals-@SKK_API_VERSION@.vapi	\
	--library skk-@SKK_API_VERSION@				\
	--gir Skk-@SKK_API_VERSION@.gir				\
	--symbols libskk.symbols				\
	$(VALAFLAGS)						\
	$(NULL)

libskk_la_CFLAGS =				\
	$(CODE_COVERAGE_CFLAGS)			\
	-I$(top_srcdir)				\
	$(LIBSKK_CFLAGS)			\
	-DPKGDATADIR=\"$(pkgdatadir)\"		\
	$(NULL)
libskk_la_LIBADD = $(LIBSKK_LIBS)
libskk_la_LDFLAGS =							\
	$(CODE_COVERAGE_LDFLAGS)					\
	-version-info "$(LT_CURRENT)":"$(LT_REVISION)":"$(LT_AGE)"	\
	-export-dynamic							\
	-export-symbols $(srcdir)/libskk.symbols			\
	$(NULL)

libskkincludedir = $(includedir)/libskk
libskkinclude_HEADERS = libskk.h

libskk_la_SOURCES =				\
	rom-kana.vala				\
	encoding.vala				\
	dict.vala				\
	file-dict.vala				\
	cdb-dict.vala				\
	user-dict.vala				\
	skkserv.vala				\
	key-event.vala				\
	key-event-filter.vala			\
	keymap.vala				\
	rule.vala				\
	map-file.vala				\
	state.vala				\
	context.vala				\
	candidate.vala				\
	candidate-list.vala			\
	nicola.vala				\
	expr.vala				\
	util.vala				\
	keysyms.vala				\
	completion.vala			\
	$(NULL)

if HAVE_INTROSPECTION
girdir = $(datadir)/gir-1.0
gir_DATA = Skk-@SKK_API_VERSION@.gir

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = Skk-@SKK_API_VERSION@.typelib

Skk-@SKK_API_VERSION@.typelib: Skk-@SKK_API_VERSION@.gir
	$(AM_V_GEN) srcdir=''; \
	test -f ./$< || srcdir=$(srcdir)/; \
	@INTROSPECTION_COMPILER@ --shared-library=libskk -o $@ $${srcdir}$<
endif

Skk-@SKK_API_VERSION@.gir skk-internals-@SKK_API_VERSION@.vapi skk-@SKK_API_VERSION@.vapi: libskk.la

GITIGNOREFILES =				\
	$(libskk_la_SOURCES:.vala=.c)		\
	libskk_la_vala.stamp			\
	libskk.h				\
	libskk-internals.h			\
	libskk.symbols				\
	$(NULL)

CLEANFILES =					\
	skk-@SKK_API_VERSION@.vapi		\
	skk-internals-@SKK_API_VERSION@.vapi	\
	Skk-@SKK_API_VERSION@.typelib		\
	Skk-@SKK_API_VERSION@.gir		\
	libskk.pc				\
	$(NULL)

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libskk.pc

vapi_DATA = skk-1.0.vapi skk-1.0.deps
vapidir = $(datadir)/vala/vapi

EXTRA_DIST = config.vapi skk-1.0.deps libskk.symbols xkbcommon.vapi

-include $(top_srcdir)/git.mk
