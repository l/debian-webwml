# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=banners
SUBS=2.1 2.2 3.0 3.1

GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHDIR)/banners/index.tags $(GETTEXTDEP)
