# This Makefile should need no changes from webwml/english/devel/debian-installer/News/2004/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../../..
CUR_DIR=devel/debian-installer/News/2005
SUBS=

include $(WMLBASE)/Make.lang

# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(wildcard 2004*.wml) \
                        $(wildcard 2004*.title) \
                        $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
                        $(GETTEXTDEP)
	$(WML) index.wml
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml $(GETTEXTDEP)
	$(WML) $(<F)
