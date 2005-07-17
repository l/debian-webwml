# This Makefile should need no changes from webwml/english/logos/banner/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=banners
SUBS=2.1 2.2 3.0 3.1

GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHDIR)/banners/index.tags $(GETTEXTDEP)
