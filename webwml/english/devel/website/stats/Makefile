# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=devel/website/stats
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

SOURCESTATS = $(shell ls $(ENGLISHDIR)/$(CUR_DIR)/*.wml)

STATSOK = $(patsubst $(ENGLISHDIR)/$(CUR_DIR)/%.wml,%.$(LANGUAGE).html, \
	$(SOURCESTATS))

ifndef SUBLANG
STATS = $(STATSOK)
else
STATS = $(sort $(foreach i,$(SUBLANG),\
	$(patsubst $(ENGLISHDIR)/$(CUR_DIR)/%.wml,%.$(LANGUAGE)-$(i).html, \
	$(SOURCESTATS))))
$(STATS): $(STATSOK)
endif

DESTSTATS = $(patsubst %.html,$(HTMLDIR)/%.html,$(STATS))

%.$(LANGUAGE).html: $(ENGLISHDIR)/$(CUR_DIR)/%.wml $(LOCALEDIR)/stats.mo
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' $(WMLBASE)/.wmlrc) \
	$(shell echo $<)
ifeq "$(LANGUAGE)" "zh"
	@$(GENERATE_ZH_VARIANTS) $* html
endif

all:: $(STATS)

install:: $(DESTSTATS)
