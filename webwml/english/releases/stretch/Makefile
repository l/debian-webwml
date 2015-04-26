# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=releases/stretch
SUBS=debian-installer

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/stretch/release.data $(TEMPLDIR)/release_info.wml

releasenotes.$(LANGUAGE).html: releasenotes.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/stretch/release.data $(TEMPLDIR)/release_info.wml \
  $(ENGLISHDIR)/releases/arches.data \
  $(wildcard $(HTMLDIR)/*/release-notes*)

installmanual.$(LANGUAGE).html: installmanual.wml $(TEMPLDIR)/release.wml \
  $(ENGLISHDIR)/releases/stretch/release.data $(TEMPLDIR)/release_info.wml \
  $(ENGLISHDIR)/releases/arches.data \
  $(wildcard $(HTMLDIR)/*/install*)
