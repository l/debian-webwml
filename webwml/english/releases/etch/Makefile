# If this makefile is not generic enough to support a translation,
# please contact debian-www.

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

$(ENGLISHSRCDIR)/$(CUR_DIR)/release.data: $(TEMPLDIR)/installer.wml
	touch $@
