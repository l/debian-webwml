# This Makefile should need no changes from webwml/english/international/l10n/templates/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=international/l10n/templates
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

LANGS_TEMPLATES  := $(shell grep 'templates:' $(ENGLISHDIR)/international/l10n/data/langs | sed -e 's/templates:  *//')

HTML_TEMPLATES   := $(foreach lang,$(LANGS_TEMPLATES),$(lang).$(LANGUAGE).html)

all:: $(HTML_TEMPLATES)

tmpl.$(LANGUAGE).tmpl: tmpl.src $(ENGLISHDIR)/$(CUR_DIR)/../dtc.def
	wml -o UNDEFu$(LANGUAGECAP):tmpl.$(LANGUAGE).tmpl@g+w tmpl.src

todo.$(LANGUAGE).html: todo.wml $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
	wml -o UNDEFu$(LANGUAGECAP):todo.$(LANGUAGE).html@g+w todo.wml
	$(WMLBASE)/../touch_translations.pl $(CURDIR)/todo.wml $(LANGUAGE)

index.$(LANGUAGE).html: index.wml
	wml -o UNDEFu$(LANGUAGECAP):index.$(LANGUAGE).html@g+w index.wml
	$(WMLBASE)/../touch_translations.pl $(CURDIR)/index.wml $(LANGUAGE)

$(HTML_TEMPLATES): tmpl.$(LANGUAGE).tmpl $(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc
	langs='$(LANGS_TEMPLATES)'; for l in $$langs; do \
   test -f gen/main-$$l.inc || :> gen/main-$$l.inc; \
   test -f gen/contrib-$$l.inc || :> gen/contrib-$$l.inc; \
   test -f gen/non-free-$$l.inc || :> gen/non-free-$$l.inc; \
   test -f gen/main-$$l.exc || :> gen/main-$$l.exc; \
   test -f gen/contrib-$$l.exc || :> gen/contrib-$$l.exc; \
   test -f gen/non-free-$$l.exc || :> gen/non-free-$$l.exc; \
   sed -e "s/@tmpl_lang@/$$l/" \
       -e "/LINE: inc-main/r gen/main-$$l.inc" \
       -e "/LINE: inc-contrib/r gen/contrib-$$l.inc" \
       -e "/LINE: inc-non-free/r gen/non-free-$$l.inc" \
       -e "/LINE: exc-main/r gen/main-$$l.exc" \
       -e "/LINE: exc-contrib/r gen/contrib-$$l.exc" \
       -e "/LINE: exc-non-free/r gen/non-free-$$l.exc" \
       tmpl.$(LANGUAGE).tmpl > $$l.$(LANGUAGE).html; \
   done

$(ENGLISHDIR)/$(CUR_DIR)/gen/main.exc: $(ENGLISHDIR)/$(CUR_DIR)/gen-templates.pl $(ENGLISHDIR)/$(CUR_DIR)/../data/unstable.ftp-master $(ENGLISHDIR)/$(CUR_DIR)/../data/unstable.non-US
	cd $(ENGLISHDIR)/$(CUR_DIR) && perl gen-templates.pl

$(ENGLISHDIR)/$(CUR_DIR)/../data/langs: $(ENGLISHDIR)/$(CUR_DIR)/../data/unstable.ftp-master $(ENGLISHDIR)/$(CUR_DIR)/../data/unstable.non-US
	cd $(ENGLISHDIR)/$(CUR_DIR)/.. && ./scripts/list-languages.pl data/unstable.ftp-master data/unstable.non-US > data/langs

clean::
	-rm -rf gen
	-rm -f tmpl.$(LANGUAGE).tmpl

