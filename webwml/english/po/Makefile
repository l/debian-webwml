# This Makefile should need no changes from webwml/english/po/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=po

include $(WMLBASE)/Make.lang

LOCALEROOT = $(WMLBASE)/../locale

DOMAINS = templates bugs countries date debian-cdd distrib doc l10n langs organization ports search security vendors others

bugs_FILES      = $(ENGLISHDIR)/Bugs/pkgreport-opts.inc
countries_FILES = $(TEMPLDIR)/countries.wml
date_FILES      = $(TEMPLDIR)/ctime.wml
debian-cdd_FILES = $(TEMPLDIR)/debian-cdd.wml
distrib_FILES	= $(ENGLISHDIR)/distrib/search_packages-form.inc \
  $(ENGLISHDIR)/distrib/search_contents-form.inc
doc_FILES       = $(ENGLISHDIR)/doc/books.def $(ENGLISHDIR)/doc/manuals.defs
l10n_FILES      = $(ENGLISHDIR)/international/l10n/dtc.def \
  $(ENGLISHDIR)/international/l10n/menu.def
langs_FILES     = $(TEMPLDIR)/language_names.wml
organization_FILES = $(ENGLISHDIR)/intro/organization.data
ports_FILES     = $(ENGLISHDIR)/ports/menu.defs \
  $(ENGLISHDIR)/ports/mips/cpu.data \
  $(shell export LC_COLLATE=C; echo $(ENGLISHDIR)/ports/*/menu.inc) \
  $(ENGLISHDIR)/misc/laptops/menu.inc
search_FILES    = $(ENGLISHDIR)/searchtmpl/search.def
security_FILES  = $(TEMPLDIR)/security.wml \
  $(TEMPLDIR)/securityreferences.wml \
  $(ENGLISHDIR)/security/faq.inc \
  $(ENGLISHDIR)/security/dsa.rdf.in \
  $(ENGLISHDIR)/security/make-ref-table.pl
vendors_FILES   = $(ENGLISHDIR)/CD/vendors/vendors.CD.def
others_FILES    = $(ENGLISHDIR)/News/press/press.tags \
  $(ENGLISHDIR)/MailingLists/mklist.tags $(ENGLISHDIR)/banners/index.tags \
  $(ENGLISHDIR)/consultants/consultant.defs \
  $(ENGLISHDIR)/devel/debian-installer/ports-status.defs \
  $(ENGLISHDIR)/devel/website/tc.data \
  $(ENGLISHDIR)/distrib/pre-installed.data $(ENGLISHDIR)/logos/index.data \
  $(ENGLISHDIR)/misc/merchandise.def $(ENGLISHDIR)/y2k/l10n.data \
  $(ENGLISHDIR)/devel/join/nm-steps.inc \
  $(ENGLISHDIR)/events/speakers/speakers.defs \
  $(ENGLISHDIR)/misc/hardware.def
templates_FILES = $(addprefix $(TEMPLDIR)/, \
  cdimage.wml common_tags.wml common_translation.wml consultant.wml \
  ddp.wml events_common.wml fixes_link.wml footer.wml languages.wml \
  links.tags.wml mirrors.wml news.wml recent_list.wml speakers.wml \
  todoitem.wml translation-check.wml url.wml users.wml votebar.wml \
  weeklynews/footer.wml legal.wml legal_tags.wml wnpp.wml) \
  $(ENGLISHDIR)/devel/website/tc.data


POTFILES = $(addprefix $(ENGLISHDIR)/po/,$(addsuffix .pot,$(DOMAINS)))
MOFILES = $(addsuffix .mo,$(DOMAINS))
SOURCEFILES = \
  $(bugs_FILES)                 \
  $(countries_FILES)            \
  $(date_FILES)                 \
  $(debian-cdd_FILES)           \
  $(distrib_FILES)              \
  $(doc_FILES)                  \
  $(l10n_FILES)                 \
  $(langs_FILES)                \
  $(organization_FILES)         \
  $(ports_FILES)                \
  $(search_FILES)               \
  $(security_FILES)             \
  $(vendors_FILES)              \
  $(others_FILES)               \
  $(templates_FILES)

ifeq "$(LANGUAGE)" "en"
all install:: $(POTFILES)
else
all install:: $(POTFILES) install-mo
endif

$(ENGLISHDIR)/po/templates.pot: # $(templates_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl templates $(templates_FILES) > $@

$(ENGLISHDIR)/po/bugs.pot: # $(bugs_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl bugs $(bugs_FILES) > $@

$(ENGLISHDIR)/po/countries.pot: # $(countries_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl countries $(countries_FILES) > $@

$(ENGLISHDIR)/po/date.pot: # $(date_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl date $(date_FILES) > $@

$(ENGLISHDIR)/po/debian-cdd.pot: # $(debian-cdd_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl debian-cdd $(debian-cdd_FILES) > $@

$(ENGLISHDIR)/po/distrib.pot: # $(date_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl distrib $(distrib_FILES) > $@

$(ENGLISHDIR)/po/doc.pot: # $(doc_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl doc $(doc_FILES) > $@

$(ENGLISHDIR)/po/l10n.pot: # $(l10n_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl l10n $(l10n_FILES) > $@

$(ENGLISHDIR)/po/langs.pot: # $(langs_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl langs $(langs_FILES) > $@

$(ENGLISHDIR)/po/organization.pot: # $(organization_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl organization $(organization_FILES) > $@

$(ENGLISHDIR)/po/ports.pot: # $(ports_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl ports $(ports_FILES) > $@

$(ENGLISHDIR)/po/search.pot: # $(search_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl search $(search_FILES) > $@

$(ENGLISHDIR)/po/security.pot: # $(security_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl security $(security_FILES) > $@

$(ENGLISHDIR)/po/vendors.pot: # $(vendors_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl vendors $(vendors_FILES) > $@

$(ENGLISHDIR)/po/others.pot: # $(others_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl others $(others_FILES) > $@

#  This target prevents breakage when a new .pot file is added
%.$(LANGUAGE).po:
	cp $(ENGLISHDIR)/po/$*.pot $@

%.mo: %.$(LANGUAGE).po $(ENGLISHDIR)/po/%.pot
	msgmerge -q $*.$(LANGUAGE).po $(ENGLISHDIR)/po/$*.pot |\
            msgfmt --statistics -o $@ -

init-po:
	for d in $(DOMAINS); do \
	  [ -f $$d.$(LANGUAGE).po ] || cp $(ENGLISHDIR)/po/$$d.pot $$d.$(LANGUAGE).po; \
	done

update-po: $(POTFILES)
	for d in $(DOMAINS); do \
	  if [ ! -e $$d.$(LANGUAGE).po ]; then cp $(ENGLISHDIR)/po/$$d.pot $$d.$(LANGUAGE).po; fi; \
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
	-rm -f *.mo

pot:
	-rm -f $(POTFILES)
	$(MAKE) $(POTFILES)

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

todo:
	-@for d in $(DOMAINS); do \
          echo "##############  $$d.$(LANGUAGE).po: " ; \
	  msgattrib --untranslated $$d.$(LANGUAGE).po; \
	done

cvsupdate:
	-@echo 'cd $(WMLBASE)/..;' `echo cvs update $(SOURCEFILES) | sed -e 's/ [^ ]*\/\.\.\// /g'`
