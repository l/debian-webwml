# This Makefile should need no changes from webwml/english/international/l10n/templates/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=international/l10n/templates
SUBS=

GETTEXTFILES += l10n.mo

include $(WMLBASE)/Make.lang

L10N_DIR = $(ENGLISHDIR)/international/l10n
DIST = unstable

LANGS_TEMPLATES  := $(shell grep 'templates:' $(L10N_DIR)/data/langs | sed -e 's/templates:  *//')

HTML_TEMPLATES   := $(foreach lang,$(LANGS_TEMPLATES),$(lang).$(LANGUAGE).html)

all:: $(HTML_TEMPLATES)

tmpl.$(LANGUAGE).tmpl: tmpl.src $(L10N_DIR)/dtc.def $(ENGLISHDIR)/$(CUR_DIR)/menu.inc $(L10N_DIR)/date.gen $(GETTEXTDEP)
	$(WML) tmpl.src

todo.$(LANGUAGE).html: $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
rank.$(LANGUAGE).html: $(ENGLISHDIR)/$(CUR_DIR)/gen/rank.inc

#   HTMLFILES do not depend upon $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
#   but this fake dependancy is added in order to force generation
#   of all files ASAP, and then prevent calling gen-files.pl more
#   than once
$(HTMLFILES): $(ENGLISHDIR)/$(CUR_DIR)/menu.inc $(L10N_DIR)/dtc.def $(L10N_DIR)/date.gen $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc $(GETTEXTDEP)

$(HTML_TEMPLATES): tmpl.$(LANGUAGE).tmpl $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
	$(L10N_DIR)/scripts/fix-files.sh $(ENGLISHDIR)/$(CUR_DIR)/gen $(LANGUAGE) $(LANGS_TEMPLATES)

$(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc $(ENGLISHDIR)/$(CUR_DIR)/gen/rank.inc $(L10N_DIR)/date.gen $(L10N_DIR)/data/langs: $(L10N_DIR)/scripts/gen-files.pl $(L10N_DIR)/data/$(DIST).gluck
	-rm -rf $(ENGLISHDIR)/$(CUR_DIR)/../*/gen
	perl $(L10N_DIR)/scripts/gen-files.pl --dist=$(DIST) --l10ndir=$(L10N_DIR)  --langs --po --templates --podebconf

clean::
	-rm -rf gen
	-rm -f tmpl.$(LANGUAGE).tmpl

install:: $(patsubst %,$(HTMLDIR)/%,$(HTML_TEMPLATES))

