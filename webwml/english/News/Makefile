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
        @echo -n " * Converting: [zh_CN.GB2312], "
        @$(B5TOGB) < news.zh-cn.rdf.tmp > news.zh-cn.rdf
        @rm -f news.zh-cn.rdf.tmp
        @$(TOCN) news.zh-cn.rdf
        @echo -n "[zh_HK.Big5], "
        @mv -f news.zh-hk.rdf.tmp news.zh-hk.rdf
        @$(TOHK) news.zh-hk.rdf
        @echo "[zh_TW.Big5]."
        @mv -f news.zh-tw.rdf.tmp news.zh-tw.rdf
        @$(TOTW) news.zh-tw.rdf
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/News/news.rdf.in
endif

all:: $(NEWSRDF)

install:: $(DESTNEWSRDF)
ifeq "$(LANGUAGE)" "en"
	test -L $(HTMLDIR)/project || ln -sf weekly $(HTMLDIR)/project
endif

$(DESTNEWSRDF): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)
ifeq "$(LANGUAGE)" "en"
	ln -sf news.en.rdf $(HTMLDIR)/news.rdf
endif

index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/$(CUR_YEAR)*.wml) \
     $(wildcard $(ENGLISHSRCDIR)/News/$(CUR_YEAR)/$(CUR_YEAR)*.wml) \
     $(wildcard $(CUR_YEAR)/$(CUR_YEAR)*.title) \
     $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
     $(TEMPLDIR)/languages.wml $(GETTEXTDEP)
