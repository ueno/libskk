include $(top_srcdir)/gtk-doc.make

DOC_MODULE = libskk
DOC_MAIN_SGML_FILE = libskk-docs.xml
DOC_SOURCE_DIR = $(top_srcdir)/libskk
MKDB_OPTIONS = --output-format=xml

INCLUDES = $(LIBSKK_CFLAGS)
GTKDOC_LIBS = $(LIBSKK_LIBS) -L$(top_builddir)/libskk -lskk -Wl,-rpath=$(top_builddir)/libskk

IGNORE_HFILES = \
	skk-internals.h
