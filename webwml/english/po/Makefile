# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=po

include $(WMLBASE)/Make.lang

LOCALEROOT = $(WMLBASE)/../locale
SHOULD_BE_REPLACED_BY_TEMPLDIR_WHEN_TESTING_IS_OVER = $(WMLBASE)/../po/template/debian

TMPL_FILES = $(wildcard $(SHOULD_BE_REPLACED_BY_TEMPLDIR_WHEN_TESTING_IS_OVER)/*.wml) $(SHOULD_BE_REPLACED_BY_TEMPLDIR_WHEN_TESTING_IS_OVER)/countries.def
POTFILE    = $(ENGLISHDIR)/po/templates.pot

ifeq "$(LANGUAGE)" "en"
all:: $(POTFILE)
else
all:: templates.mo
install:: install-mo
endif

$(POTFILE): $(TMPL_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../po=english $(TMPL_FILES) > $@

new.templates.$(LANGUAGE).po: templates.$(LANGUAGE).po $(POTFILE)
	msgmerge templates.$(LANGUAGE).po $(POTFILE) -o $@

templates.mo: new.templates.$(LANGUAGE).po
	msgfmt --statistics -o $@ new.templates.$(LANGUAGE).po

install-mo:
	[ -d $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES ] || mkdir -p $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES
	if [ -f $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/templates.mo ]; then \
       cmp templates.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/templates.mo >/dev/null 2>&1 \
       || cp -f templates.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/templates.mo; \
     else \
       cp -f templates.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/templates.mo; \
     fi

clean::
	-rm -f *.pot *.mo

