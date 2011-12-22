INCLUDES = -I$(top_srcdir) $(LIBSKK_CFLAGS)

TESTS_ENVIRONMENT = LIBSKK_DATA_PATH=$(top_srcdir)
TESTS = rom-kana file-dict user-dict context
noinst_PROGRAMS = $(TESTS)
noinst_HEADERS = common.h

AM_CPPFLAGS = -DLIBSKK_FILE_DICT=\"$(top_srcdir)/tests/file-dict.dat\"

rom_kana_SOURCES = rom-kana.c
rom_kana_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

# kana_kan_SOURCES = kana-kan.c
# kana_kan_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

file_dict_SOURCES = file-dict.c
file_dict_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

user_dict_SOURCES = user-dict.c common.c
user_dict_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

context_SOURCES = context.c common.c
context_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

EXTRA_DIST = file-dict.dat kana-kan.c
CLEANFILES = user-dict.dat

-include $(top_srcdir)/git.mk
