distclean_dirs = \
	libskk \
	gtk-doc \
	$(NULL)

phony_deps = \
	libskk-doc \
	libskk-gtk-doc \
	$(NULL)

libskkdocdir=$(datadir)/devhelp/references/libskk
libskkimgdir=$(datadir)/devhelp/references/libskk/img

libskkgtkdocdir=$(datadir)/gtk-doc/html/libskk

common_doc_files = \
	*.css \
	*.png \
	*.js \
	index.htm \
	*.html \
	$(NULL)

libskkdoc_DATA = \
	libskk/libskk/libskk.devhelp2 \
	$(addprefix libskk/libskk/,$(common_doc_files)) \
	$(NULL)

libskkgtkdoc_DATA = gtk-doc/libskk/html/*

libskkimg_DATA = \
	libskk/libskk/img/*.png \
	$(NULL)

dist_man_MANS = skk.1

$(libskkdoc_DATA) $(libskkimg_DATA): libskk-doc
$(libskkgtkdoc_DATA): libskk-gtk-doc

valadoc_flags = \
	--force \
	--package-version $(PACKAGE_VERSION) \
	$(NULL)

# libskk documentation
libskk_doc_files_blacklist = \
	$(top_srcdir)/libskk/kana-kan.vala \
	$(NULL)
# this expands the list of files, so we can filter out elements
libskk_doc_files_all = \
	$(wildcard $(top_srcdir)/libskk/*.vala) \
	$(NULL)
# FIXME: sort the files manually to work around the native doclet portion of
# bgo#662784
libskk_doc_files = \
	$(sort \
	$(filter-out $(libskk_doc_files_blacklist),$(libskk_doc_files_all)))
libskk_doc_deps = \
	config \
	glib-2.0 \
	gio-2.0 \
	gee-1.0 \
	posix \
	json-glib-1.0 \
	$(NULL)
valadoc_flags_libskk = \
	$(valadoc_flags) \
	-X $(top_srcdir)/libskk/libskk.h \
	$(addprefix --pkg=,$(libskk_doc_deps)) \
	--vapidir=$(top_srcdir)/libskk \
	$(libskk_doc_files) \
	$(NULL)

libskk-doc: $(libskk_doc_files)
	$(AM_V_GEN)$(VALADOC) \
		-o libskk/ \
		--doclet=devhelp \
		$(valadoc_flags_libskk) \
		$(NULL)

libskk-gtk-doc: $(libskk_doc_files)
	$(AM_V_GEN)$(VALADOC) \
		-X -l -X $(top_builddir)/libskk/.libs/libskk.so \
		-o gtk-doc/libskk \
		--doclet=gtkdoc \
		$(valadoc_flags_libskk) \
		$(NULL)

.PHONY: $(phony_deps)

distclean-local: distclean-docs
distclean-docs:
	rm -rf $(distclean_dirs)

GITIGNOREFILES = \
	libskk/ \
	gtk-doc/ \
	$(NULL)

-include $(top_srcdir)/git.mk
