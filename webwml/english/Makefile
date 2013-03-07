# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=.
CUR_DIR=
SUBS=Bugs CD MailingLists News Pics banners consultants devel \
distrib doc events intro international legal logos mirror misc partners \
ports releases reports security users volatile vote women y2k

all install:: install-locale

clean:: clean-locale

include $(WMLBASE)/Make.lang

ifndef SUBLANG
SITEMAP = sitemap.$(LANGUAGE).html
DESTSITEMAP = $(HTMLDIR)/$(SITEMAP)
SEARCHXML = search.$(LANGUAGE).xml
DESTSEARCHXML =  $(HTMLDIR)/$(SEARCHXML)
else
SITEMAP = $(sort $(foreach i,$(SUBLANG),\
	$(patsubst %.wml,%.$(LANGUAGE)-$(i).html,sitemap.wml)))
DESTSITEMAP = $(patsubst %.html,$(HTMLDIR)/%.html,$(SITEMAP))
SEARCHXML = $(sort $(foreach i,$(SUBLANG),$(subst search,search.$(LANGUAGE)-$(i),search.xml)))
DESTSEARCHXML = $(patsubst %.xml,$(HTMLDIR)/%.xml,$(SEARCHXML))
endif

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/mainpage.wml $(GETTEXTDEP) \
		$(wildcard News/$(CUR_YEAR)/[0-9]*.wml) $(wildcard $(ENGLISHSRCDIR)/News/$(CUR_YEAR)/[0-9]*.wml) \
     		$(wildcard News/$(CUR_YEAR)/[0-9]*.title) \
		$(wildcard security/$(CUR_YEAR)/dsa-[0-9]*.wml) $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-[0-9]*.wml) \
		$(TEMPLDIR)/ctime.wml $(TEMPLDIR)/recent_list.wml $(TEMPLDIR)/languages.wml \
		$(TEMPLDIR)/release_info.wml $(TEMPLDIR)/release_images.wml
	$(WML) index.wml

$(SITEMAP): $(ENGLISHDIR)/sitemap.wml $(TEMPLDIR)/card.wml \
  $(TEMPLDIR)/links.tags.wml $(TEMPLDIR)/template.wml $(GETTEXTDEP) \
  $(TEMPLDIR)/release_info.wml $(ENGLISHDIR)/MailingLists/mklist.tags
ifeq "$(LANGUAGE)" "zh"
	@echo -n "Processing $(<F): "
	$(subst :.zh,:sitemap.zh,$(WML)) \
          $(shell egrep '^-D (CUR_|CHAR)' .wmlrc) \
            $(shell echo $(ENGLISHDIR) | sed s,./,,)/sitemap.wml
	@$(GENERATE_ZH_VARIANTS) sitemap html
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' .wmlrc) \
          $(shell echo $(ENGLISHDIR) | sed s,./,,)/sitemap.wml
endif

ifneq "$(LANGUAGE)" "en"
contact.$(LANGUAGE).html : contact.wml $(WMLBASE)/../.wmlrc $(WMLBASE)/.wmlrc \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
  $(ENGLISHDIR)/devel/website/tc.data $(LOCALEDIR)/others.mo
endif

all:: $(SITEMAP) $(SEARCHXML)

install:: $(DESTSITEMAP) $(DESTSEARCHXML)
ifeq "$(LANGUAGE)" "en"

install:: $(HTMLDIR)/favicon.ico

$(HTMLDIR)/favicon.ico: favicon.ico
	install -p -m 664 favicon.ico $(HTMLDIR)
endif

$(SEARCHXML): $(ENGLISHDIR)/search.xml.in $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "zh"
	@echo -n "Processing $(<F): "
	$(shell echo $(WML) | perl -pe 's,:.zh-(..)\.html,:search.zh-$$1.xml,g') \
	$(shell egrep '^-D (CUR_|CHAR)' .wmlrc) \
	  $(shell echo $(ENGLISHDIR) | sed s,./,,)/search.xml.in
	@$(GENERATE_ZH_VARIANTS) search xml
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' .wmlrc) \
	  $(shell echo $(ENGLISHDIR) | sed s,./,,)/search.xml.in
endif

$(DESTSEARCHXML): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)

install-locale:
	$(MAKE) -C po install

clean-locale:
	$(MAKE) -C po clean
