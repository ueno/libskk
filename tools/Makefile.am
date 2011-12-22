# force include config.h before gi18n.h.
AM_CPPFLAGS = -include $(CONFIG_HEADER)

bin_PROGRAMS = skk

skk_VALAFLAGS =					\
	--vapidir=$(top_srcdir)/libskk		\
	--pkg config --pkg skk-1.0		\
	$(VALAFLAGS)

skk_CFLAGS =					\
	-I$(top_srcdir)				\
	$(LIBSKK_CFLAGS)			\
	-DDATADIR=\"$(datadir)\"		\
	-DPKGDATADIR=\"$(pkgdatadir)\"		\
	-DLOCALEDIR=\"$(datadir)/locale\"
skk_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)
skk_SOURCES = tool.vala

GITIGNOREFILES =				\
	$(skk_SOURCES:.vala=.c)			\
	skk_vala.stamp				\
	$(NULL)

-include $(top_srcdir)/git.mk
