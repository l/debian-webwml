# This Makefile should need no changes from webwml/english/releases/etch/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=releases/etch
SUBS=debian-installer

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/etch/release.data $(TEMPLDIR)/release_info.wml

releasenotes.$(LANGUAGE).html: releasenotes.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/etch/release.data $(TEMPLDIR)/release_info.wml \
  $(wildcard $(HTMLDIR)/*/release-notes*)

installmanual.$(LANGUAGE).html: installmanual.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/etch/release.data $(TEMPLDIR)/release_info.wml \
  $(wildcard $(HTMLDIR)/*/install*)

etchnhalf.$(LANGUAGE).html: etchnhalf.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/etch/release.data
