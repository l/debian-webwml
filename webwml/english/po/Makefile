# This Makefile should need no changes from webwml/english/po/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=po

include $(WMLBASE)/Make.lang

LOCALEROOT = $(WMLBASE)/../locale

DOMAINS = templates bugs doc l10n organization ports search others

POTFILES = $(addprefix $(ENGLISHDIR)/po/,$(addsuffix .pot,$(DOMAINS)))
MOFILES = $(addsuffix .mo,$(DOMAINS))

TEMPLATE_FILES  = $(wildcard $(TEMPLDIR)/*.wml $(TEMPLDIR)/*/*.wml) $(TEMPLDIR)/countries.def
BUGS_FILES      = $(ENGLISHDIR)/Bugs/pkgreport-opts.inc
DOC_FILES       = $(ENGLISHDIR)/doc/books.def $(ENGLISHDIR)/doc/manuals.defs
L10N_FILES      = $(ENGLISHDIR)/international/l10n/dtc.def $(ENGLISHDIR)/international/l10n/menu.def
ORGANIZATION_FILES = $(ENGLISHDIR)/intro/organization.tags
PORTS_FILES     = $(ENGLISHDIR)/ports/menu.defs $(ENGLISHDIR)/ports/mips/cpu.data $(wildcard $(ENGLISHDIR)/ports/*/menu.inc)
SEARCH_FILES    = $(ENGLISHDIR)/searchtmpl/search.def
OTHERS_FILES    = $(ENGLISHDIR)/News/press/press.tags $(ENGLISHDIR)/MailingLists/mklist.tags $(ENGLISHDIR)/banners/index.tags $(ENGLISHDIR)/consultants/consultant.defs $(ENGLISHDIR)/distrib/pre-installed.data $(ENGLISHDIR)/logos/index.tags $(ENGLISHDIR)/misc/laptops/menu.inc $(ENGLISHDIR)/misc/merchandise.def $(ENGLISHDIR)/security/faq.inc $(ENGLISHDIR)/y2k/l10n.data

ifeq "$(LANGUAGE)" "en"
all:: $(POTFILES)
else
all:: $(MOFILES)
install:: install-mo
endif

$(ENGLISHDIR)/po/templates.pot: $(TEMPLATE_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(TEMPLATE_FILES) > $@

$(ENGLISHDIR)/po/bugs.pot: $(BUGS_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(BUGS_FILES) > $@

$(ENGLISHDIR)/po/doc.pot: $(DOC_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(DOC_FILES) > $@

$(ENGLISHDIR)/po/l10n.pot: $(L10N_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(L10N_FILES) > $@

$(ENGLISHDIR)/po/organization.pot: $(ORGANIZATION_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(ORGANIZATION_FILES) > $@

$(ENGLISHDIR)/po/ports.pot: $(PORTS_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(PORTS_FILES) > $@

$(ENGLISHDIR)/po/search.pot: $(SEARCH_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(SEARCH_FILES) > $@

$(ENGLISHDIR)/po/others.pot: $(OTHERS_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(OTHERS_FILES) > $@

%.mo: %.$(LANGUAGE).po
	msgfmt --statistics -o $@ $*.$(LANGUAGE).po

init-po:
	for d in $(DOMAINS); do \
	  cp $(ENGLISHDIR)/po/$$d.pot $$d.$(LANGUAGE).po; \
	done

update-po:
	for d in $(DOMAINS); do \
	  msgmerge -q $$d.$(LANGUAGE).po $(ENGLISHDIR)/po/$$d.pot -o $$d.$(LANGUAGE).po.new && mv $$d.$(LANGUAGE).po.new $$d.$(LANGUAGE).po; \
	done

install-mo: $(MOFILES)
	[ -d $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES ] || mkdir -p $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES
	for d in $(DOMAINS); do \
          if [ -f $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$$d.mo ]; then \
            cmp $$d.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$$d.mo >/dev/null 2>&1 \
            || cp -f $$d.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$$d.mo; \
          else \
            cp -f $$d.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$$d.mo; \
          fi; \
        done

clean::
	-rm -f *.pot *.mo

