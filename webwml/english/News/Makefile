# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=News
# list any subdirectories in the following variable. If a listed directory
# exists, it must contain a Makefile, or make gives an error
YEARS:=$(wildcard [12][0-9][0-9][0-9])
SUBS=$(YEARS) weekly press

GETTEXTFILES += newsevents.mo

include $(WMLBASE)/Make.lang

clean::
	rm -f $(NEWSRDF)
ifeq "$(LANGUAGE)" "ja"
	rm -f $(NEWSRDF).tmp
endif

ifndef SUBLANG
NEWSRDF     := news.$(LANGUAGE).rdf
DESTNEWSRDF     := $(HTMLDIR)/$(NEWSRDF)
else
NEWSRDF     := $(sort $(foreach i,$(SUBLANG),$(subst news,news.$(LANGUAGE)-$(i),news.rdf)))
DESTNEWSRDF     := $(patsubst %.rdf,$(HTMLDIR)/%.rdf,$(NEWSRDF))
endif

$(NEWSRDF): $(ENGLISHDIR)/News/news.rdf.in \
  $(wildcard $(CUR_YEAR)/*.wml) \
  $(wildcard $(ENGLISHDIR)/News/$(CUR_YEAR)/*.wml) \
  $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "zh"
	$(shell echo $(WML) | perl -pe 's,:.zh-(..)\.html,:news.zh-$$1.rdf,g') \
          $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/News/news.rdf.in
	@$(GENERATE_ZH_VARIANTS) news rdf
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
	    $(ENGLISHDIR)/News/news.rdf.in
endif

all:: $(NEWSRDF)

install:: $(DESTNEWSRDF)

$(DESTNEWSRDF): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)

index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/$(CUR_YEAR)*.wml) \
     $(wildcard $(ENGLISHSRCDIR)/News/$(CUR_YEAR)/$(CUR_YEAR)*.wml) \
     $(wildcard $(CUR_YEAR)/$(CUR_YEAR)*.title) \
     $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
     $(TEMPLDIR)/languages.wml $(GETTEXTDEP) \
     $(ENGLISHSRCDIR)/News/index.include
