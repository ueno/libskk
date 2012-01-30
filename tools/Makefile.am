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

# force include config.h before gi18n.h.
AM_CPPFLAGS = -include $(CONFIG_HEADER)

bin_PROGRAMS = skk

skk_VALAFLAGS =					\
	--vapidir=$(top_srcdir)/libskk		\
	--vapidir=$(top_srcdir)/tools		\
	--pkg config				\
	--pkg skk-1.0				\
	$(VALAFLAGS)

skk_CFLAGS =					\
	-I$(top_srcdir)				\
	$(LIBSKK_CFLAGS)			\
	-DDATADIR=\"$(datadir)\"		\
	-DPKGDATADIR=\"$(pkgdatadir)\"		\
	-DLOCALEDIR=\"$(datadir)/locale\"	\
	$(NULL)
skk_LDADD = $(top_builddir)/libskk/libskk.la $(LIBSKK_LIBS)
skk_SOURCES = tool.vala

dist_man_MANS = skk.1

if ENABLE_FEP
skk_VALAFLAGS += --pkg libfep-glib -D ENABLE_FEP
skk_CFLAGS += $(LIBFEP_CFLAGS)
skk_LDADD += $(LIBFEP_LIBS)
skk_SOURCES += fep.vala
dist_man_MANS += skkfep.1

EXTRA_DIST = skkfep.in skkfep.wrapper.in
bin_SCRIPTS = skkfep
libexec_SCRIPTS = skkfep.wrapper

skkfep: skkfep.in
	$(AM_V_GEN) sed -e "s!@FEP\@!"$(FEP)"!" \
	-e "s!@libexecdir\@!"$(libexecdir)"!" \
	$< > $@.tmp && \
	mv $@.tmp $@

skkfep.wrapper: skkfep.wrapper.in
	$(AM_V_GEN) sed -e "s!@bindir\@!"$(bindir)"!" \
	$< > $@.tmp && \
	mv $@.tmp $@
endif

GITIGNOREFILES =				\
	$(skk_SOURCES:.vala=.c)			\
	skk_vala.stamp				\
	$(NULL)

-include $(top_srcdir)/git.mk
