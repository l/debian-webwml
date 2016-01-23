# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=blends
SUBS=Pics hamradio gis

GETTEXTFILES += blends.mo

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
	$(ENGLISHDIR)/blends/blend.defs $(ENGLISHDIR)/blends/released.data \
	$(ENGLISHDIR)/blends/unreleased.data $(GETTEXTDEP)
