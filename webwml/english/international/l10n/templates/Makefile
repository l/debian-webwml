# This Makefile should need no changes from webwml/english/international/l10n/templates/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=international/l10n/templates
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

L10N_DIR = $(ENGLISHDIR)/international/l10n

LANGS_TEMPLATES  := $(shell grep 'templates:' $(L10N_DIR)/data/langs | sed -e 's/templates:  *//')

HTML_TEMPLATES   := $(foreach lang,$(LANGS_TEMPLATES),$(lang).$(LANGUAGE).html)

all:: $(HTML_TEMPLATES)

tmpl.$(LANGUAGE).tmpl: tmpl.src $(L10N_DIR)/dtc.def
	wml -o UNDEFu$(LANGUAGECAP):tmpl.$(LANGUAGE).tmpl@g+w tmpl.src

todo.$(LANGUAGE).html: todo.wml $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
	wml -o UNDEFu$(LANGUAGECAP):todo.$(LANGUAGE).html@g+w todo.wml
	$(WMLBASE)/../touch_translations.pl $(CURDIR)/todo.wml $(LANGUAGE)

index.$(LANGUAGE).html: index.wml
	wml -o UNDEFu$(LANGUAGECAP):index.$(LANGUAGE).html@g+w index.wml
	$(WMLBASE)/../touch_translations.pl $(CURDIR)/index.wml $(LANGUAGE)

$(HTML_TEMPLATES): tmpl.$(LANGUAGE).tmpl $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
	$(L10N_DIR)/scripts/fix-files.sh $(ENGLISHDIR)/$(CUR_DIR)/gen $(LANGUAGE) $(LANGS_TEMPLATES)

$(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc: $(L10N_DIR)/scripts/gen-files.pl $(L10N_DIR)/data/unstable.ftp-master $(L10N_DIR)/data/unstable.non-US
	-rm -rf $(ENGLISHDIR)/$(CUR_DIR)/gen
	perl $(L10N_DIR)/scripts/gen-files.pl --l10ndir=$(L10N_DIR)  --templates

$(L10N_DIR)/data/langs: $(L10N_DIR)/data/unstable.ftp-master $(L10N_DIR)/data/unstable.non-US
	perl $(L10N_DIR)/scripts/gen-files.pl --l10ndir=$(L10N_DIR)  --langs

clean::
	-rm -rf gen
	-rm -f tmpl.$(LANGUAGE).tmpl

install:: $(patsubst %,$(HTMLDIR)/%,$(HTML_TEMPLATES))

