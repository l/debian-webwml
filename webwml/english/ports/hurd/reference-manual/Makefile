# Nothing translatable here.

WMLBASE=../../..
CUR_DIR=ports/hurd/reference-manual
SUBS=

include $(WMLBASE)/Make.lang


rmsources := $(wildcard *.html)
rmdestfiles := $(patsubst %,$(HTMLDIR)/%,$(rmsources))

install:: $(rmdestfiles)

$(rmdestfiles): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(rmdestfiles)
