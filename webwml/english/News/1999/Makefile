# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=News/1999
SUBS=

GETTEXTFILES += newsevents.mo

NOGENERICDEP := true
include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(wildcard 1999*.wml) \
                        $(wildcard 1999*.title)\
                        $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
                        $(GETTEXTDEP)
	$(WML) index.wml
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml $(GETTEXTDEP)
	$(WML) $(<F)
