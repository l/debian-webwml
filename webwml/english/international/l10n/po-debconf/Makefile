# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=international/l10n/po-debconf
SUBS=

GETTEXTFILES += l10n.mo

include $(WMLBASE)/Make.lang

L10N_DIR = $(ENGLISHDIR)/international/l10n
DIST = unstable
SORT_PKGS = $(L10N_DIR)/data/popcon

LANGS_PODEBCONF  := $(shell grep 'podebconf:' $(L10N_DIR)/data/langs | sed -e 's/podebconf:  *//')

HTML_PODEBCONF   := $(foreach lang,$(LANGS_PODEBCONF),$(lang).$(LANGUAGE).html)

# Ugly hard-coded list of almost complete languages
LANGS_PODECB90	:= cs de es fr pt ru sv
HTML_PODEBC90	:= $(foreach lang,$(LANGS_PODECB90),$(lang).$(LANGUAGE).html)

LANGS_PODEBCNOT	:= $(filter-out $(LANGS_PODECB90),$(LANGS_PODEBCONF))
HTML_PODEBCNOT	:= $(foreach lang,$(LANGS_PODEBCNOT),$(lang).$(LANGUAGE).html)

all:: $(HTML_PODEBCONF)

tmpl90.$(LANGUAGE).tmpl: tmpl90.src $(L10N_DIR)/dtc.def $(ENGLISHDIR)/$(CUR_DIR)/menu.inc $(L10N_DIR)/date.gen $(GETTEXTDEP)
	$(WML) tmpl90.src
tmpl.$(LANGUAGE).tmpl: tmpl.src $(L10N_DIR)/dtc.def $(ENGLISHDIR)/$(CUR_DIR)/menu.inc $(L10N_DIR)/date.gen $(GETTEXTDEP)
	$(WML) tmpl.src

pot.$(LANGUAGE).html: $(ENGLISHDIR)/$(CUR_DIR)/gen/main.orig
rank.$(LANGUAGE).html: $(ENGLISHDIR)/$(CUR_DIR)/gen/rank.inc

#   HTMLFILES do not depend upon $(ENGLISHDIR)/$(CUR_DIR)/gen/main.orig
#   but this fake dependancy is added in order to force generation
#   of all files ASAP, and then prevent calling gen-files.pl more
#   than once
$(HTMLFILES): $(ENGLISHDIR)/$(CUR_DIR)/menu.inc $(L10N_DIR)/dtc.def $(L10N_DIR)/date.gen $(ENGLISHDIR)/$(CUR_DIR)/gen/main.orig $(GETTEXTDEP)

$(HTML_PODEBC90): tmpl90.$(LANGUAGE).tmpl $(ENGLISHDIR)/$(CUR_DIR)/gen/main.orig
	$(L10N_DIR)/scripts/fix-files.sh $(ENGLISHDIR)/$(CUR_DIR)/gen $(LANGUAGE) tmpl90 $(LANGS_PODECB90)

$(HTML_PODEBCNOT): tmpl.$(LANGUAGE).tmpl $(ENGLISHDIR)/$(CUR_DIR)/gen/main.orig
	$(L10N_DIR)/scripts/fix-files.sh $(ENGLISHDIR)/$(CUR_DIR)/gen $(LANGUAGE) tmpl $(LANGS_PODEBCNOT)

$(ENGLISHDIR)/$(CUR_DIR)/gen/main.orig $(ENGLISHDIR)/$(CUR_DIR)/gen/rank.inc $(L10N_DIR)/date.gen $(L10N_DIR)/data/langs: $(L10N_DIR)/scripts/gen-files.pl $(L10N_DIR)/data/$(DIST)
	-rm -rf $(ENGLISHDIR)/$(CUR_DIR)/../*/gen
	$(L10N_DIR)/scripts/isoquery.pl
	perl $(L10N_DIR)/scripts/gen-files.pl --sort=$(SORT_PKGS) --dist=$(DIST) --l10ndir=$(L10N_DIR)  --langs --po --podebconf --po4a

clean::
	-rm -rf gen
	-rm -f tmpl90.$(LANGUAGE).tmpl
	-rm -f tmpl.$(LANGUAGE).tmpl
	-rm -f $(L10N_DIR)/*.dir $(L10N_DIR)/*.pag

install:: $(patsubst %,$(HTMLDIR)/%,$(HTML_PODEBCONF))

