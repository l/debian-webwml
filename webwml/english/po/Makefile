# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=po

include $(WMLBASE)/Make.lang

LOCALEROOT = $(WMLBASE)/../locale

SHOULD_BE_REPLACED_BY_TEMPLDIR_WHEN_TESTING_IS_OVER = $(WMLBASE)/../po/template/debian
TEMPLATE_FILES  = $(wildcard $(SHOULD_BE_REPLACED_BY_TEMPLDIR_WHEN_TESTING_IS_OVER)/*.wml) $(SHOULD_BE_REPLACED_BY_TEMPLDIR_WHEN_TESTING_IS_OVER)/countries.def
TEMPLATE_POT    = $(ENGLISHDIR)/po/templates.pot

SHOULD_BE_REPLACED_BY_ENGLISH_PORTS_WHEN_TESTING_IS_OVER = $(WMLBASE)/../po/ports
PORTS_FILES     = $(SHOULD_BE_REPLACED_BY_ENGLISH_PORTS_WHEN_TESTING_IS_OVER)/menu.defs $(SHOULD_BE_REPLACED_BY_ENGLISH_PORTS_WHEN_TESTING_IS_OVER)/mips/cpu.data $(wildcard $(SHOULD_BE_REPLACED_BY_ENGLISH_PORTS_WHEN_TESTING_IS_OVER)/*/menu.inc)
PORTS_POT       = $(ENGLISHDIR)/po/ports.pot

ifeq "$(LANGUAGE)" "en"
all:: $(TEMPLATE_POT) $(PORTS_POT)
else
all:: templates.mo ports.mo
install:: install-mo
endif

#   Templates files
$(TEMPLATE_POT): $(TEMPLATE_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../po=english $(TEMPLATE_FILES) > $@

new.templates.$(LANGUAGE).po: templates.$(LANGUAGE).po $(TEMPLATE_POT)
	msgmerge templates.$(LANGUAGE).po $(TEMPLATE_POT) -o $@

templates.mo: new.templates.$(LANGUAGE).po
	msgfmt --statistics -o $@ new.templates.$(LANGUAGE).po

#   Ports menus
$(PORTS_POT): $(PORTS_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../po=english $(PORTS_FILES) > $@

new.ports.$(LANGUAGE).po: ports.$(LANGUAGE).po $(PORTS_POT)
	msgmerge ports.$(LANGUAGE).po $(PORTS_POT) -o $@

ports.mo: new.ports.$(LANGUAGE).po
	msgfmt --statistics -o $@ new.ports.$(LANGUAGE).po

install-mo:
	[ -d $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES ] || mkdir -p $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES
	if [ -f $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/templates.mo ]; then \
       cmp templates.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/templates.mo >/dev/null 2>&1 \
       || cp -f templates.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/templates.mo; \
     else \
       cp -f templates.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/templates.mo; \
     fi
	if [ -f $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/ports.mo ]; then \
       cmp ports.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/ports.mo >/dev/null 2>&1 \
       || cp -f ports.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/ports.mo; \
     else \
       cp -f ports.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/ports.mo; \
     fi

clean::
	-rm -f *.pot *.mo

