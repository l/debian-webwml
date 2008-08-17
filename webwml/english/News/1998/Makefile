# This Makefile should need no changes from webwml/english/News/1998/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=News/1998
SUBS=

GETTEXTFILES += newsevents.mo

NOGENERICDEP := true
include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(wildcard 1998*.wml) \
                        $(wildcard 1998*.title)\
                        $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
                        $(GETTEXTDEP)
	$(WML) index.wml
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml $(GETTEXTDEP)
	$(WML) $(<F)
