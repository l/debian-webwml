# This Makefile should need no changes from webwml/english/logos/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=logos
SUBS=

GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHDIR)/logos/index.data \
  $(GETTEXTDEP) \
  $(ENGLISHDIR)/logos/openlogo-25.jpg $(ENGLISHDIR)/logos/openlogo-nd-25.jpg \
  $(ENGLISHDIR)/logos/officiallogo-25.jpg $(ENGLISHDIR)/logos/officiallogo-nd-25.jpg \
  $(ENGLISHDIR)/logos/button-1.gif $(ENGLISHDIR)/logos/button-2.gif \
  $(ENGLISHDIR)/logos/button-3.jpg $(ENGLISHDIR)/logos/button-k1.png \
  $(ENGLISHDIR)/logos/button-k2.png $(ENGLISHDIR)/logos/banner_64.gif \
  $(ENGLISHDIR)/logos/banner_wp.gif $(ENGLISHDIR)/logos/banner_h.gif \
  $(ENGLISHDIR)/logos/banner_a.gif $(ENGLISHDIR)/logos/banner_v.jpg \
  $(ENGLISHDIR)/logos/gnuart.png $(ENGLISHDIR)/logos/debart_logo_04.png
