# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=po

include $(WMLBASE)/Make.lang

LOCALEROOT = $(WMLBASE)/../locale

DOMAINS = templates bugs cdimage consultants countries date distrib doc l10n langs legal mailinglists newsevents organization ports search security vendors vote wnpp others

bugs_FILES      = $(ENGLISHDIR)/Bugs/pkgreport-opts.inc
cdimage_FILES   = $(TEMPLDIR)/cdimage.wml
consultants_FILES = $(TEMPLDIR)/consultant.wml \
  $(ENGLISHDIR)/consultants/consultant.defs
countries_FILES = $(TEMPLDIR)/countries.wml
date_FILES      = $(TEMPLDIR)/ctime.wml
distrib_FILES	= $(ENGLISHDIR)/distrib/search_packages-form.inc \
  $(ENGLISHDIR)/distrib/search_contents-form.inc \
  $(ENGLISHDIR)/releases/arches.data
doc_FILES       = $(ENGLISHDIR)/doc/books.def $(ENGLISHDIR)/doc/manuals.defs
l10n_FILES      = $(ENGLISHDIR)/international/l10n/dtc.def \
  $(ENGLISHDIR)/international/l10n/menu.def
langs_FILES     = $(TEMPLDIR)/language_names.wml
legal_FILES     = $(addprefix $(TEMPLDIR)/, legal.wml legal_tags.wml)
mailinglists_FILES = $(ENGLISHDIR)/MailingLists/mklist.tags
newsevents_FILES = $(addprefix $(TEMPLDIR)/, \
  events_common.wml news.wml speakers.wml \
  projectnews/footer.wml weeklynews/footer.wml) \
  $(ENGLISHDIR)/News/press/press.tags \
  $(ENGLISHDIR)/events/speakers/speakers.defs \
  $(ENGLISHDIR)/events/talks.defs \
  $(ENGLISHDIR)/News/news.rdf.in
organization_FILES = $(ENGLISHDIR)/intro/organization.data
ports_FILES     = $(ENGLISHDIR)/ports/menu.defs \
  $(shell export LC_COLLATE=C; echo $(ENGLISHDIR)/ports/*/menu.inc) \
  $(ENGLISHDIR)/misc/laptops/menu.inc
search_FILES    = $(ENGLISHDIR)/searchtmpl/search.def
security_FILES  = $(TEMPLDIR)/security.wml \
  $(TEMPLDIR)/securityreferences.wml \
  $(ENGLISHDIR)/security/faq.inc \
  $(ENGLISHDIR)/security/dsa.rdf.in \
  $(ENGLISHDIR)/security/make-ref-table.pl
vendors_FILES   = $(ENGLISHDIR)/CD/vendors/vendors.CD.def
vote_FILES      = $(TEMPLDIR)/votebar.wml
wnpp_FILES      = $(TEMPLDIR)/wnpp.wml
others_FILES    = $(ENGLISHDIR)/banners/index.tags \
  $(ENGLISHDIR)/devel/debian-installer/ports-status.defs \
  $(ENGLISHDIR)/devel/website/tc.data \
  $(ENGLISHDIR)/distrib/pre-installed.data $(ENGLISHDIR)/logos/index.data \
  $(ENGLISHDIR)/misc/merchandise.def $(ENGLISHDIR)/y2k/l10n.data \
  $(ENGLISHDIR)/devel/join/nm-steps.inc \
  $(ENGLISHDIR)/misc/hardware.def \
  $(ENGLISHDIR)/mirror/submit.inc
templates_FILES = $(addprefix $(TEMPLDIR)/, \
  common_tags.wml common_translation.wml \
  ddp.wml fixes_link.wml footer.wml languages.wml \
  links.tags.wml mirrors.wml recent_list.wml release.wml \
  todoitem.wml translation-check.wml url.wml users.wml)


POTFILES = $(addprefix $(ENGLISHDIR)/po/,$(addsuffix .pot,$(DOMAINS)))
MOFILES = $(addsuffix .mo,$(DOMAINS))
SOURCEFILES = \
  $(bugs_FILES)                 \
  $(cdimage_FILES)              \
  $(consultants_FILES)          \
  $(countries_FILES)            \
  $(date_FILES)                 \
  $(distrib_FILES)              \
  $(doc_FILES)                  \
  $(l10n_FILES)                 \
  $(langs_FILES)                \
  $(legal_FILES)                \
  $(mailinglists_FILES)         \
  $(newsevents_FILES)           \
  $(organization_FILES)         \
  $(ports_FILES)                \
  $(search_FILES)               \
  $(security_FILES)             \
  $(vendors_FILES)              \
  $(vote_FILES)                 \
  $(wnpp_FILES)                 \
  $(others_FILES)               \
  $(templates_FILES)

all install:: $(POTFILES) install-mo

$(ENGLISHDIR)/po/templates.pot: # $(templates_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl templates $(templates_FILES) > $@

$(ENGLISHDIR)/po/bugs.pot: # $(bugs_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl bugs $(bugs_FILES) > $@

$(ENGLISHDIR)/po/cdimage.pot: # $(cdimage_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl cdimage $(cdimage_FILES) > $@

$(ENGLISHDIR)/po/consultants.pot: # $(consultants_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl consultants $(consultants_FILES) > $@

$(ENGLISHDIR)/po/countries.pot: # $(countries_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl countries $(countries_FILES) > $@

$(ENGLISHDIR)/po/date.pot: # $(date_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl date $(date_FILES) > $@

$(ENGLISHDIR)/po/distrib.pot: # $(date_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl distrib $(distrib_FILES) > $@

$(ENGLISHDIR)/po/doc.pot: # $(doc_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl doc $(doc_FILES) > $@

$(ENGLISHDIR)/po/l10n.pot: # $(l10n_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl l10n $(l10n_FILES) > $@

$(ENGLISHDIR)/po/langs.pot: # $(langs_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl langs $(langs_FILES) > $@

$(ENGLISHDIR)/po/legal.pot: # $(legal_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl legal $(legal_FILES) > $@

$(ENGLISHDIR)/po/mailinglists.pot: # $(mailinglists_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl mailinglists $(mailinglists_FILES) > $@

$(ENGLISHDIR)/po/newsevents.pot: # $(newsevents_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl newsevents $(newsevents_FILES) > $@

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

$(ENGLISHDIR)/po/vote.pot: # $(vote_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl vote $(vote_FILES) > $@

$(ENGLISHDIR)/po/wnpp.pot: # $(wnpp_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl wnpp $(wnpp_FILES) > $@

$(ENGLISHDIR)/po/others.pot: # $(others_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl others $(others_FILES) > $@

ifeq "$(LANGUAGE)" "en"

init-po:
update-po:
install-mo:
stats:

pot:
	rm -f $(POTFILES)
	$(MAKE) $(POTFILES)

gen-%.pot:
	potfile=$(ENGLISHDIR)/po/$*.pot; \
	rm -f $$potfile; \
	$(MAKE) $$potfile

cvsupdate:
	@echo 'cd $(WMLBASE)/..;' `echo cvs update $(SOURCEFILES) | sed -e 's/ [^ ]*\/\.\.\// /g'`

else # not english

%.$(LANGUAGE).po: $(ENGLISHDIR)/po/%.pot
# this prevents breakage when a new .pot file is added
	@[ -f $@ ] || cp $(ENGLISHDIR)/po/$*.pot $@

%.mo: %.$(LANGUAGE).po
	msgmerge -q $*.$(LANGUAGE).po $(ENGLISHDIR)/po/$*.pot | \
            msgfmt --statistics -o $@ -

init-po:
	for d in $(DOMAINS); do \
	  [ -f $$d.$(LANGUAGE).po ] || cp $(ENGLISHDIR)/po/$$d.pot $$d.$(LANGUAGE).po; \
	done

update-po: $(POTFILES)
	for d in $(DOMAINS); do \
	  if [ ! -e $$d.$(LANGUAGE).po ]; then cp $(ENGLISHDIR)/po/$$d.pot $$d.$(LANGUAGE).po; fi; \
	  msgmerge --previous -F -q $$d.$(LANGUAGE).po $(ENGLISHDIR)/po/$$d.pot -o $$d.$(LANGUAGE).po.new && mv $$d.$(LANGUAGE).po.new $$d.$(LANGUAGE).po; \
	done

update-%.$(LANGUAGE).po:
	msgmerge --previous -F -q $*.$(LANGUAGE).po $(ENGLISHDIR)/po/$*.pot -o $*.$(LANGUAGE).po.new
	mv $*.$(LANGUAGE).po.new $*.$(LANGUAGE).po

# can't have this here, it's like that in Makefile.common
# DESTMOFILES := $(addprefix $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/,$(MOFILES))
# 
# $(DESTMOFILES): $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/%.mo: %.mo
# 	@[ -d $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES ] || mkdir -p $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES
# 	@cp -vu $< $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$<

INSTMOFILES := $(addprefix install-,$(MOFILES))

$(INSTMOFILES): install-%.mo: %.mo
	@[ -d $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES ] || mkdir -p $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES
	@cp -vu $< $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$<

install-mo: $(INSTMOFILES)

clean::
	rm -f *.mo


# TODO: there a bug here: if the translation .po files doesn't exist (i.e.
# nothing translated), the stats are incorrect. 
stats: $(POTFILES)
# Suppress errors from msgmerge as they corrupt translation stats on
# the Debian website
	-@for d in $(DOMAINS); do \
		echo -n "$$d.$(LANGUAGE).po: " 1>&2; \
		if [ -e $$d.$(LANGUAGE).po ]; then \
			msgmerge -q $$d.$(LANGUAGE).po $(ENGLISHDIR)/po/$$d.pot 2>/dev/null | \
			msgfmt -o /dev/null --statistics -; \
		else \
			echo -n $$(egrep '^msgid ' $(ENGLISHDIR)/po/$$d.pot | wc -l); \
			echo ' untranslated messages.'; \
		fi; \
	done

todo:
	-@for d in $(DOMAINS); do \
          echo "##############  $$d.$(LANGUAGE).po: " ; \
	  msgattrib --untranslated $$d.$(LANGUAGE).po; \
	done

endif # english or not
