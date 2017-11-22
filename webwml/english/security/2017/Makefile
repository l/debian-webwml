# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=security/2017
SUBS=

GETTEXTFILES += security.mo

NOGENERICDEP := true
include $(WMLBASE)/Make.lang


ifndef SUBLANG
INDEXPAGE = index.$(LANGUAGE).html
else
INDEXPAGE = $(sort $(foreach i,$(SUBLANG),$(subst index,index.$(LANGUAGE)-$(i),index.html)))
endif

$(INDEXPAGE): index.wml  \
  $(wildcard dsa-[0-9]*.wml) $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/dsa-[0-9]*.data) \
  $(wildcard dla-[0-9]*.wml) $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/dla-[0-9]*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list_security.wml $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "zh"
	@echo -n "Processing $(<F): "
	$(shell echo $(WML) | perl -pe 's,:.zh-(..)\.html,:index.zh-$$1.html,g') \
          $(shell egrep '^-D (CUR_|CHAR)' ../../.wmlrc) \
          $(ENGLISHSRCDIR)/$(CUR_DIR)/index.wml
	  @$(GENERATE_ZH_VARIANTS) index html
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' ../../.wmlrc) \
          $(ENGLISHSRCDIR)/$(CUR_DIR)/index.wml
endif

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/security.wml \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/%.data $(GETTEXTDEP)
	$(WML) $(<F)
ifeq "$(LANGUAGE)" "zh"
	@$(GENERATE_ZH_VARIANTS) $* html
endif



