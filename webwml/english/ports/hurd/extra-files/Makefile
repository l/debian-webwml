# Nothing translatable here.

WMLBASE=../../..
CUR_DIR=ports/hurd/extra-files
SUBS=

include $(WMLBASE)/Make.lang


efsources := cross-install native-install dpkg-hurd
efdestfiles := $(patsubst %,$(HTMLDIR)/%,$(efsources))

install:: $(efdestfiles)

$(efdestfiles): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(efdestfiles)
