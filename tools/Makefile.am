# Copyright (C) 2011 Daiki Ueno <ueno@unixuser.org>
# Copyright (C) 2011 Red Hat, Inc.

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

GITIGNOREFILES =				\
	$(skk_SOURCES:.vala=.c)			\
	skk_vala.stamp				\
	$(NULL)

-include $(top_srcdir)/git.mk
