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

AC_PREREQ(2.63)
AC_CONFIG_MACRO_DIR([m4])

AC_INIT([libskk], [0.0.11], [ueno@unixuser.org])

SKK_API_VERSION=1.0
SKK_API_MAJOR_VERSION=1
SKK_API_MINOR_VERSION=0
SKK_API_PC_VERSION=1.0
SKK_LIBRARY_SUFFIX="-$SKK_API_VERSION"

AC_SUBST([SKK_API_VERSION])
AC_SUBST([SKK_API_MAJOR_VERSION])
AC_SUBST([SKK_API_MINOR_VERSION])
AC_SUBST([SKK_API_PC_VERSION])
AC_SUBST([SKK_LIBRARY_SUFFIX])
AC_SUBST([SKK_LIBRARY_SUFFIX_U],[AS_TR_SH([$SKK_LIBRARY_SUFFIX])])

dnl Init automake
AM_INIT_AUTOMAKE([color-tests])
AM_MAINTAINER_MODE([enable])
AC_GNU_SOURCE

dnl Check for programs
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_CC_STDC
AC_PROG_INSTALL
IT_PROG_INTLTOOL

# define PACKAGE_VERSION_* variables
AM_DISABLE_STATIC
AC_ISC_POSIX
AC_HEADER_STDC
LT_INIT

# If library source has changed since last release, increment revision
# If public symbols have been added, removed or changed since last release,
#  increment current and set revision to 0
# If public symbols have been added since last release, increment age
# If public symbols have been removed since last release, set age to 0
m4_define([libskk_lt_current], [0])
m4_define([libskk_lt_revision], [0])
m4_define([libskk_lt_age], [0])
LT_CURRENT=libskk_lt_current
LT_REVISION=libskk_lt_revision
LT_AGE=libskk_lt_age
AC_SUBST([LT_CURRENT])
AC_SUBST([LT_REVISION])
AC_SUBST([LT_AGE])

# check gio
PKG_CHECK_MODULES([GIO], [gio-2.0], ,
  [AC_MSG_ERROR([can't find gio-2.0])])

# check gee
PKG_CHECK_MODULES([GEE], [gee-1.0], ,
  [AC_MSG_ERROR([can't find gee-1.0])])

# check json-glib
PKG_CHECK_MODULES([JSON_GLIB], [json-glib-1.0], ,
  [AC_MSG_ERROR([can't find json-glib-1.0])])

LIBSKK_CFLAGS="$GIO_CFLAGS $GEE_CFLAGS $JSON_GLIB_CFLAGS"
AC_SUBST(LIBSKK_CFLAGS)
LIBSKK_LIBS="$GIO_LIBS $GEE_LIBS $JSON_GLIB_LIBS"
AC_SUBST(LIBSKK_LIBS)

GOBJECT_INTROSPECTION_CHECK([0.9.0])

AM_PROG_VALAC([0.12.0])
AC_SUBST(VALAC)
AC_SUBST(VALAFLAGS)

# define GETTEXT_* variables
GETTEXT_PACKAGE=libskk
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE", [Define to the read-only architecture-independent data directory.])

AC_ARG_ENABLE([fep],
              AS_HELP_STRING([--enable-fep],
                             [compile with libfep]),
              [enable_fep=$enableval], [enable_fep=no])
if test x$enable_fep = xyes; then
   PKG_CHECK_MODULES([LIBFEP], [libfep-glib >= 0.0.7], , enable_fep=no)
   VALA_CHECK_PACKAGES([libfep-glib], , enable_fep=no)
   AC_PATH_PROG([FEP], [fep])
fi
AM_CONDITIONAL([ENABLE_FEP], [test x$enable_fep = xyes])

AC_ARG_ENABLE([docs],
              AS_HELP_STRING([--enable-docs],[Enable documentation generation]),
              [enable_docs=$enableval], [enable_docs=no])
AM_CONDITIONAL([ENABLE_DOCS], [test x$enable_docs = xyes])

VALADOC_REQUIRED=0.3.1

have_valadoc=no
if test x$enable_docs = xyes; then
  # make sure the library is new enough and the program exists
  PKG_CHECK_MODULES([VALADOC], [valadoc-1.0 >= $VALADOC_REQUIRED])
  AC_PATH_PROG([VALADOC], [valadoc], [:])
  AS_IF([test "$VALADOC" != :], have_valadoc=yes)
fi
AM_CONDITIONAL([HAVE_VALADOC], [test x$have_valadoc = xyes])

if test "x$enable_docs" = "xyes" -a "x$have_valadoc" != "xyes"; then
    AC_MSG_ERROR([Doc building requested but valadoc not installed.])
fi

AC_ARG_ENABLE([code-coverage],
              AS_HELP_STRING([--enable-code-coverage],
                             [compile with code coverage code]),
              [enable_code_coverage=$enableval], [enable_code_coverage=no])

# Only enable code coverage if this isn't a release.
if test "x$enable_code_coverage" = "xyes"; then
    CODE_COVERAGE_CFLAGS="-fprofile-arcs -ftest-coverage -O0 -ggdb"
    CODE_COVERAGE_LDFLAGS="-lgcov"
fi

AC_SUBST([CODE_COVERAGE_CFLAGS])
AC_SUBST([CODE_COVERAGE_LDFLAGS])

AC_ARG_ENABLE([valgrind-tests],
              AS_HELP_STRING([--enable-valgrind-tests],
                             [run self tests under valgrind]),
              [enable_valgrind_tests=$enableval], [enable_valgrind_tests=no])

# Run self-tests under valgrind?
if test "x$enable_valgrind_tests" = "xyes"; then
    AC_CHECK_PROGS(VALGRIND, valgrind)
fi

if test -n "$VALGRIND"; then
    VALGRIND_OPTS="--leak-check=full --show-reachable=no --gen-suppressions=all --num-callers=20 --error-exitcode=0 --log-file=valgrind.log.%p"
    AC_SUBST(VALGRIND_OPTS)
fi

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile
libskk/Makefile
libskk/libskk.pc
rules/Makefile
tools/Makefile
tests/Makefile
docs/Makefile
po/Makefile.in])
AC_OUTPUT
