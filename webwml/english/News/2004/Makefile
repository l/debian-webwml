# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=News/2004
SUBS=

GETTEXTFILES += newsevents.mo

NOGENERICDEP := true
include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml $(GETTEXTDEP)
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml $(wildcard 2004*.wml) \
  $(wildcard $(ENGLISHDIR)/News/2004/2004*.wml) $(GETTEXTDEP)

20040524.%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml $(TEMPLDIR)/news_events.wml $(GETTEXTDEP)
	$(WML) $(<F)
20041015.%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml $(TEMPLDIR)/news_events.wml $(GETTEXTDEP)
	$(WML) $(<F)
