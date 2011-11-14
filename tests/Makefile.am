INCLUDES = -I$(top_srcdir) $(LIBSKK_CFLAGS)

TESTS = rom-kana file-dict user-dict context
noinst_PROGRAMS = $(TESTS)

rom_kana_SOURCES = rom-kana.c
rom_kana_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

# kana_kan_SOURCES = kana-kan.c
# kana_kan_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

file_dict_SOURCES = file-dict.c
file_dict_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

user_dict_SOURCES = user-dict.c
user_dict_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

context_SOURCES = context.c
context_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

EXTRA_DIST = kana-kan.c

