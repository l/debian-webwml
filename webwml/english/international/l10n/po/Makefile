# This Makefile should need no changes from webwml/english/international/l10n/po/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=international/l10n/po
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

L10N_DIR = $(ENGLISHDIR)/international/l10n

LANGS_PO  := $(shell grep 'po:' $(L10N_DIR)/data/langs | sed -e 's/po: *//')

HTML_PO   := $(foreach lang,$(LANGS_PO),$(lang).$(LANGUAGE).html)

all:: $(HTML_PO)

tmpl.$(LANGUAGE).tmpl: tmpl.src $(L10N_DIR)/dtc.def
	wml -o UNDEFu$(LANGUAGECAP):tmpl.$(LANGUAGE).tmpl@g+w tmpl.src

todo.$(LANGUAGE).html: todo.wml $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
	wml -o UNDEFu$(LANGUAGECAP):todo.$(LANGUAGE).html@g+w todo.wml
	$(WMLBASE)/../touch_translations.pl $(CURDIR)/todo.wml $(LANGUAGE)

index.$(LANGUAGE).html: index.wml
	wml -o UNDEFu$(LANGUAGECAP):index.$(LANGUAGE).html@g+w index.wml
	$(WMLBASE)/../touch_translations.pl $(CURDIR)/index.wml $(LANGUAGE)

$(HTML_PO): tmpl.$(LANGUAGE).tmpl $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
	$(L10N_DIR)/scripts/fix-files.sh $(ENGLISHDIR)/$(CUR_DIR)/gen $(LANGUAGE) $(LANGS_PO)

$(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc: $(L10N_DIR)/scripts/gen-files.pl $(L10N_DIR)/data/unstable.ftp-master $(L10N_DIR)/data/unstable.non-US
	-rm -rf $(ENGLISHDIR)/$(CUR_DIR)/gen
	perl $(L10N_DIR)/scripts/gen-files.pl --l10ndir=$(L10N_DIR)  --po

$(L10N_DIR)/data/langs: $(L10N_DIR)/data/unstable.ftp-master $(L10N_DIR)/data/unstable.non-US
	perl $(L10N_DIR)/scripts/gen-files.pl --l10ndir=$(L10N_DIR)  --langs

clean::
	-rm -rf gen
	-rm -f tmpl.$(LANGUAGE).tmpl

install:: $(patsubst %,$(HTMLDIR)/%,$(HTML_TEMPLATES))

