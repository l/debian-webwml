# This Makefile should need no changes from webwml/english/po/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=po

include $(WMLBASE)/Make.lang

LOCALEROOT = $(WMLBASE)/../locale

DOMAINS = templates bugs countries doc l10n langs organization ports search vendors others

POTFILES = $(addprefix $(ENGLISHDIR)/po/,$(addsuffix .pot,$(DOMAINS)))
MOFILES = $(addsuffix .mo,$(DOMAINS))

bugs_FILES      = $(ENGLISHDIR)/Bugs/pkgreport-opts.inc
countries_FILES = $(TEMPLDIR)/countries.wml
doc_FILES       = $(ENGLISHDIR)/doc/books.def $(ENGLISHDIR)/doc/manuals.defs
l10n_FILES      = $(ENGLISHDIR)/international/l10n/dtc.def \
  $(ENGLISHDIR)/international/l10n/menu.def
langs_FILES     = $(TEMPLDIR)/language_names.wml
organization_FILES = $(ENGLISHDIR)/intro/organization.tags
ports_FILES     = $(ENGLISHDIR)/ports/menu.defs \
  $(ENGLISHDIR)/ports/mips/cpu.data \
  $(wildcard $(ENGLISHDIR)/ports/*/menu.inc) \
  $(ENGLISHDIR)/misc/laptops/menu.inc
search_FILES    = $(ENGLISHDIR)/searchtmpl/search.def
vendors_FILES   = $(ENGLISHDIR)/CD/vendors/vendors.CD.def
others_FILES    = $(ENGLISHDIR)/News/press/press.tags \
  $(ENGLISHDIR)/MailingLists/mklist.tags $(ENGLISHDIR)/banners/index.tags \
  $(ENGLISHDIR)/consultants/consultant.defs \
  $(ENGLISHDIR)/devel/website/tc.data \
  $(ENGLISHDIR)/distrib/pre-installed.data $(ENGLISHDIR)/logos/index.tags \
  $(ENGLISHDIR)/misc/merchandise.def $(ENGLISHDIR)/security/faq.inc \
  $(ENGLISHDIR)/y2k/l10n.data
templates_FILES = $(addprefix $(TEMPLDIR)/, \
  cdimage.wml common_tags.wml common_translation.wml consultant.wml \
  ddp.wml events_common.wml fixes_link.wml footer.wml languages.wml \
  links.tags.wml mirrors.wml news.wml recent_list.wml security_tags.wml \
  todoitem.wml translation-check.wml url.wml votebar.wml \
  weeklynews/footer.wml)

ifeq "$(LANGUAGE)" "en"
all install:: $(POTFILES)
else
all install:: $(POTFILES) install-mo
endif

$(ENGLISHDIR)/po/templates.pot: $(templates_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(templates_FILES) > $@

$(ENGLISHDIR)/po/bugs.pot: $(bugs_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(bugs_FILES) > $@

$(ENGLISHDIR)/po/countries.pot: $(countries_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(countries_FILES) > $@

$(ENGLISHDIR)/po/doc.pot: $(doc_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(doc_FILES) > $@

$(ENGLISHDIR)/po/l10n.pot: $(l10n_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(l10n_FILES) > $@

$(ENGLISHDIR)/po/langs.pot: $(langs_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(langs_FILES) > $@

$(ENGLISHDIR)/po/organization.pot: $(organization_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(organization_FILES) > $@

$(ENGLISHDIR)/po/ports.pot: $(ports_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(ports_FILES) > $@

$(ENGLISHDIR)/po/search.pot: $(search_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(search_FILES) > $@

$(ENGLISHDIR)/po/vendors.pot: $(vendors_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(vendors_FILES) > $@

$(ENGLISHDIR)/po/others.pot: $(others_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl $(others_FILES) > $@

%.mo: %.$(LANGUAGE).po $(ENGLISHDIR)/po/%.pot
	msgmerge -q $*.$(LANGUAGE).po $(ENGLISHDIR)/po/$*.pot |\
            msgfmt --statistics -o $@ -

init-po:
	for d in $(DOMAINS); do \
	  [ -f $$d.$(LANGUAGE).po ] || cp $(ENGLISHDIR)/po/$$d.pot $$d.$(LANGUAGE).po; \
	done

update-po: $(POTFILES)
	for d in $(DOMAINS); do \
	  msgmerge -F -q $$d.$(LANGUAGE).po $(ENGLISHDIR)/po/$$d.pot -o $$d.$(LANGUAGE).po.new && mv $$d.$(LANGUAGE).po.new $$d.$(LANGUAGE).po; \
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

ifeq "$(LANGUAGE)" "en"
stats:
else
stats: $(POTFILES)
	-@for d in $(DOMAINS); do \
          echo -n "$$d.$(LANGUAGE).po: " 1>&2; \
          msgmerge -q $$d.$(LANGUAGE).po $(ENGLISHDIR)/po/$$d.pot |\
             msgfmt -o /dev/null --statistics -; \
        done
endif

