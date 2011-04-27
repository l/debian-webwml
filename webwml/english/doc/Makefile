# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE	:= ..
CUR_DIR	:= $(subst $(shell cd $(WMLBASE); pwd -P)/,,$(shell pwd))
SUBS	:=# remove subdirectories that you don't want built from this variable

GETTEXTFILES += doc.mo

include $(WMLBASE)/Make.lang


books.$(LANGUAGE).html: books.wml $(ENGLISHSRCDIR)/doc/books.def \
  $(TEMPLDIR)/countries.wml $(TEMPLDIR)/language_names.wml $(TEMPLDIR)/url.wml
ddp.$(LANGUAGE).html: ddp.wml $(TEMPLDIR)/ddp.wml
todo.$(LANGUAGE).html: todo.wml $(TEMPLDIR)/ddp.wml
docpolicy.$(LANGUAGE).html: docpolicy.wml $(TEMPLDIR)/ddp.wml
cvs.$(LANGUAGE).html: cvs.wml $(TEMPLDIR)/ddp.wml $(ENGLISHSRCDIR)/doc/dirtree.jpg
topics.$(LANGUAGE).html: topics.wml $(TEMPLDIR)/ddp.wml
user-manuals.$(LANGUAGE).html: user-manuals.wml $(TEMPLDIR)/ddp.wml \
  $(ENGLISHSRCDIR)/doc/manuals.defs $(ENGLISHSRCDIR)/doc/user-manuals.defs
devel-manuals.$(LANGUAGE).html: devel-manuals.wml $(TEMPLDIR)/ddp.wml \
  $(ENGLISHSRCDIR)/doc/manuals.defs $(ENGLISHSRCDIR)/doc/devel-manuals.defs
misc-manuals.$(LANGUAGE).html: misc-manuals.wml $(TEMPLDIR)/ddp.wml $(ENGLISHSRCDIR)/doc/manuals.defs

ifeq "$(LANGUAGE)" "en"

textfiles := map-reference.txt

desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

$(desttextfiles): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)

install:: $(desttextfiles)

cleandest::
	rm -f $(desttextfiles)

endif

