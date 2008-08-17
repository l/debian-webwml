# This Makefile should need no changes from webwml/english/devel/debian-installer/News/2003/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../../..
CUR_DIR=devel/debian-installer/News/2003
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*.wml) \
                        $(wildcard [0-9]*.title) \
                        $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
                        $(GETTEXTDEP)
	$(WML) index.wml
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml $(GETTEXTDEP)
	$(WML) $(<F)
