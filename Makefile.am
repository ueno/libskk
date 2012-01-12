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

SUBDIRS = libskk rules tools tests po
DISTCHECK_CONFIGURE_FLAGS = --enable-docs

if HAVE_VALADOC
SUBDIRS += docs
endif

GITIGNOREFILES =				\
	INSTALL					\
	aclocal.m4				\
	compile					\
	config.guess				\
	config.h.in				\
	config.sub				\
	depcomp					\
	install-sh				\
	ltmain.sh				\
	missing					\
	mkinstalldirs				\
	m4					\
	$(top_builddir)/lcov.html/*		\
	$(NULL)

MAINTAINERCLEANFILES =				\
	$(top_builddir)/lcov.info		\
	$(NULL)

EXTRA_DIST = lcov.mk

maintainer-clean-local: maintainer-clean-local-lcov
maintainer-clean-local-lcov:
	rm -rf $(top_builddir)/lcov.html

.PHONY: maintainer-clean-local-lcov

# Code coverage support
include $(top_srcdir)/lcov.mk

-include $(top_srcdir)/git.mk
