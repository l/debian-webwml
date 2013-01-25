# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=international/l10n/po
SUBS=

GETTEXTFILES += l10n.mo

include $(WMLBASE)/Make.lang

L10N_DIR = $(ENGLISHDIR)/international/l10n
DIST = unstable
SORT_PKGS = $(L10N_DIR)/data/popcon

LANGS_PO  := $(shell grep 'po:' $(L10N_DIR)/data/langs | sed -e 's/po: *//')

HTML_PO   := $(foreach lang,$(LANGS_PO),$(lang).$(LANGUAGE).html)

all:: $(HTML_PO)

tmpl.$(LANGUAGE).tmpl: tmpl.src $(L10N_DIR)/dtc.def $(ENGLISHDIR)/$(CUR_DIR)/menu.inc $(L10N_DIR)/date.gen $(GETTEXTDEP)
	$(WML) tmpl.src

todo.$(LANGUAGE).html: $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
rank.$(LANGUAGE).html: $(ENGLISHDIR)/$(CUR_DIR)/gen/rank.inc

#   HTMLFILES do not depend upon $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
#   but this fake dependancy is added in order to force generation
#   of all files ASAP, and then prevent calling gen-files.pl more
#   than once
$(HTMLFILES): $(ENGLISHDIR)/$(CUR_DIR)/menu.inc $(L10N_DIR)/dtc.def $(L10N_DIR)/date.gen $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc $(GETTEXTDEP)

$(HTML_PO): tmpl.$(LANGUAGE).tmpl $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
	$(L10N_DIR)/scripts/fix-files.sh $(ENGLISHDIR)/$(CUR_DIR)/gen $(LANGUAGE) tmpl $(LANGS_PO)

$(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc $(ENGLISHDIR)/$(CUR_DIR)/gen/rank.inc $(L10N_DIR)/date.gen $(L10N_DIR)/data/langs: $(L10N_DIR)/scripts/gen-files.pl $(L10N_DIR)/data/$(DIST)
	-rm -rf $(ENGLISHDIR)/$(CUR_DIR)/../*/gen
	$(L10N_DIR)/scripts/isoquery.pl
	perl $(L10N_DIR)/scripts/gen-files.pl --sort=$(SORT_PKGS) --dist=$(DIST) --l10ndir=$(L10N_DIR)  --langs --po --podebconf --po4a

clean::
	-rm -rf gen
	-rm -f tmpl.$(LANGUAGE).tmpl
	-rm -f $(L10N_DIR)/*.dir $(L10N_DIR)/*.pag

install:: $(patsubst %,$(HTMLDIR)/%,$(HTML_PO))

