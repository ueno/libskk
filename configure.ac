AC_PREREQ(2.63)
AC_CONFIG_MACRO_DIR([m4])

AC_INIT([libskk], [0.0.1], [ueno@unixuser.org])

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
AM_INIT_AUTOMAKE
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

AM_PATH_GLIB_2_0
PKG_CHECK_MODULES([LIBSKK], [glib-2.0 >= 2.26.0 gobject-2.0 gio-2.0 gee-1.0 json-glib-1.0], ,
  [AC_MSG_ERROR([Required libraries are not found])])
GLIB_GSETTINGS

GOBJECT_INTROSPECTION_CHECK([0.9.0])

AM_PROG_VALAC([0.14.0])
AC_SUBST(VALAC)
AC_SUBST(VALAFLAGS)

# define GETTEXT_* variables
GETTEXT_PACKAGE=libskk
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE", [Define to the read-only architecture-independent data directory.])

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

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile
libskk/Makefile
libskk/libskk.pc
tools/Makefile
tests/Makefile
docs/Makefile
data/Makefile
data/rom-kana/Makefile
po/Makefile.in])
AC_OUTPUT
