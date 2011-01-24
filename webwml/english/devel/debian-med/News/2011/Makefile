# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../../..
CUR_DIR=devel/debian-med/News/2011
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(wildcard 2011*.wml) \
                        $(wildcard 2011*.title)\
                        $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml
	$(WML) index.wml
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml
	$(WML) $(<F)
