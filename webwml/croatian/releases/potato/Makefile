# This Makefile should need no changes from webwml/english/releases/potato/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=releases/potato
SUBS=installguide

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(ENGLISHDIR)/releases/info
installmanual.$(LANGUAGE).html: installmanual.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/potato/release.data
releasenotes.$(LANGUAGE).html: releasenotes.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/potato/release.data
