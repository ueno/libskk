lib_LTLIBRARIES = libskk.la

libskk_la_VALAFLAGS = \
	--includedir=libskk \
	-H libskk.h --vapi skk-@SKK_API_VERSION@.vapi \
	-h skk-internals.h \
	--vapidir=. \
	--pkg config --pkg glib-2.0 --pkg gio-2.0 --pkg gee-1.0 \
	--pkg posix --pkg json-glib-1.0 \
	--internal-vapi skk-internals-@SKK_API_VERSION@.vapi \
	--library skk-@SKK_API_VERSION@ --gir Skk-@SKK_API_VERSION@.gir \
	$(VALAFLAGS)

libskk_la_CFLAGS = \
	$(LIBSKK_CFLAGS) \
	-DROMKANADIR=\"$(romkanadir)\"

libskk_la_LIBADD = \
	$(LIBSKK_LIBS)

libskkincludedir = $(includedir)/libskk

skk_headers = \
	libskk.h

libskkinclude_HEADERS = \
	$(skk_headers)

romkanadir = $(pkgdatadir)/rom-kana
romkana_DATA = standard.json kzik.json

libskk_la_SOURCES = \
	rom-kana.vala \
	kana-kan.vala \
	encoding.vala \
	dict.vala \
	file-dict.vala \
	user-dict.vala \
	skkserv.vala \
	key-event.vala \
	state.vala \
	context.vala \
	util.vala

if HAVE_INTROSPECTION
girdir = $(datadir)/gir-1.0
gir_DATA = Skk-@SKK_API_VERSION@.gir

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = Skk-@SKK_API_VERSION@.typelib

Skk-@SKK_API_VERSION@.typelib: Skk-@SKK_API_VERSION@.gir
	@INTROSPECTION_COMPILER@ --shared-library=libskk -o $@ $^
endif

Skk-@SKK_API_VERSION@.gir skk-internals-@SKK_API_VERSION@.vapi skk-@SKK_API_VERSION@.vapi: libskk.la

CLEANFILES = \
	skk-@SKK_API_VERSION@.vapi \
	skk-internals-@SKK_API_VERSION@.vapi \
	Skk-@SKK_API_VERSION@.typelib \
	Skk-@SKK_API_VERSION@.gir \
	*.[ch] \
	*.pc

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libskk.pc

vapi_DATA = skk-1.0.vapi skk-1.0.deps
vapidir = $(datadir)/vala/vapi

EXTRA_DIST = config.vapi

