# Makefile for webwml/english/devel/debian-med/News/2002

WMLBASE=../../../..
CUR_DIR=devel/debian-med/News/2002
SUBS=

include $(WMLBASE)/Make.lang


# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(wildcard 2002*.wml) \
                        $(wildcard 2002*.title)\
                        $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml
	$(WML) index.wml
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml
	$(WML) $(<F)
