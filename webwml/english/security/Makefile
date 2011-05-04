# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=security
SUBS=undated $(wildcard [12][0-9][0-9][0-9]) audit oval key-rollover
# TODO: Check that 'oval' works now that RT #160 (rt.debian.org) has been closed

GETTEXTFILES += security.mo

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(TEMPLDIR)/release_info.wml \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)

pam-auth.$(LANGUAGE).html: pam-auth.wml \
  $(ENGLISHSRCDIR)/security/pam-auth.wml

faq.$(LANGUAGE).html: faq.wml \
  $(ENGLISHSRCDIR)/security/faq.wml \
  $(ENGLISHSRCDIR)/security/faq.inc $(GETTEXTDEP)

$(ENGLISHSRCDIR)/security/ref-table.inc: $(ENGLISHSRCDIR)/security/make-ref-table.pl $(wildcard $(ENGLISHSRCDIR)/security/*/*.data) 
	perl $(ENGLISHSRCDIR)/security/make-ref-table.pl -p -a >$(ENGLISHSRCDIR)/security/ref-table.inc

crossreferences.$(LANGUAGE).html:: $(ENGLISHSRCDIR)/security/ref-table.inc \
	$(ENGLISHDIR)/template/debian/securityreferences.wml 

clean::
	rm -f $(DSARDF) $(DSALONGRDF)
ifeq "$(LANGUAGE)" "ja"
	rm -f $(DSARDF).tmp $(DSALONGRDF).tmp
endif
	rm -f ref-table.inc

ifndef SUBLANG
DSARDF     := dsa.$(LANGUAGE).rdf
DSALONGRDF := dsa-long.$(LANGUAGE).rdf
DSAALLRDF := dsa-all.$(LANGUAGE).rdf
DESTDSARDF     := $(HTMLDIR)/$(DSARDF)
DESTDSALONGRDF := $(HTMLDIR)/$(DSALONGRDF)
else
DSARDF     := $(sort $(foreach i,$(SUBLANG),$(subst dsa,dsa.$(LANGUAGE)-$(i),dsa.rdf)))
DSALONGRDF := $(sort $(foreach i,$(SUBLANG),$(subst dsa-long,dsa-long.$(LANGUAGE)-$(i),dsa-long.rdf)))
DSAALLRDF := $(sort $(foreach i,$(SUBLANG),$(subst dsa-all,dsa-all.$(LANGUAGE)-$(i),dsa-all.rdf)))
DESTDSARDF     := $(patsubst %.rdf,$(HTMLDIR)/%.rdf,$(DSARDF))
DESTDSALONGRDF := $(patsubst %.rdf,$(HTMLDIR)/%.rdf,$(DSALONGRDF))
endif

$(DSARDF): $(ENGLISHDIR)/security/dsa.rdf.in \
  $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "zh"
	@echo -n "Processing $(<F): "
	$(shell echo $(WML) | perl -pe 's,:.zh-(..)\.html,:dsa.zh-$$1.rdf,g') \
          $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa.rdf.in
	@$(GENERATE_ZH_VARIANTS) dsa rdf
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa.rdf.in
endif

$(DSALONGRDF): $(ENGLISHDIR)/security/dsa-long.rdf.in \
  $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "zh"
	@echo -n "Processing $(<F): "
	$(shell echo $(WML) | perl -pe 's,:.zh-(..)\.html,:dsa-long.zh-$$1.rdf,g') \
          $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa-long.rdf.in
	@$(GENERATE_ZH_VARIANTS) dsa-long rdf
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa-long.rdf.in
endif

$(DSAALLRDF): $(ENGLISHDIR)/security/dsa-all.rdf.in \
  $(wildcard ????/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/????/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/????/dsa-*.data) \
  $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "zh"
	@echo -n "Processing $(<F): "
	$(shell echo $(WML) | perl -pe 's,:.zh-(..)\.html,:dsa-all.zh-$$1.rdf,g') \
          $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa-all.rdf.in
	@$(GENERATE_ZH_VARIANTS) dsa-all rdf
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa-all.rdf.in
endif


all:: $(DSARDF) $(DSALONGRDF)

install:: $(DESTDSARDF) $(DESTDSALONGRDF)

$(DESTDSARDF): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)
$(DESTDSALONGRDF): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)


ifeq "$(LANGUAGE)" "en"

map := $(HTMLDIR)/map-dsa.txt

$(map): $(wildcard $(CUR_YEAR)/dsa-*.wml)
	for i in 2*/dsa-*.wml; do echo $$i $$i | sed -r 's/^.+\/(.+) /\1 /' | sed 's/\.wml//g' | sed 's/^dsa-//' ;done > $(HTMLDIR)/map-dsa.txt

install:: $(map)

cleandest::
	rm -f $(map)

endif


