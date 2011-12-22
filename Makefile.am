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
	$(NULL)

-include $(top_srcdir)/git.mk
