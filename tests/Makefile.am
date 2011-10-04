INCLUDES = -I$(top_srcdir) $(LIBSKK_CFLAGS)

TESTS = rom-kana file-dict
noinst_PROGRAMS = $(TESTS)

rom_kana_SOURCES = rom-kana.c
rom_kana_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)

file_dict_SOURCES = file-dict.c
file_dict_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)
