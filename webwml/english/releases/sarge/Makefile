# This Makefile should need no changes from webwml/english/releases/sarge/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=releases/sarge
SUBS=

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/sarge/release.data $(ENGLISHDIR)/releases/info

releasenotes.$(LANGUAGE).html: releasenotes.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/sarge/release.data $(ENGLISHDIR)/releases/info \
  $(wildcard $(HTMLDIR)/*/release-notes*)

installmanual.$(LANGUAGE).html: installmanual.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/sarge/release.data $(ENGLISHDIR)/releases/info \
  $(wildcard $(HTMLDIR)/*/install*)
