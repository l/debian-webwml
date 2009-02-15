# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=releases/etch/debian-installer
SUBS=

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html:: $(ENGLISHDIR)/releases/etch/release.data \
	$(TEMPLDIR)/release_info.wml \
	$(TEMPLDIR)/installer.wml

etchnhalf.$(LANGUAGE).html:: $(ENGLISHDIR)/releases/etch/release.data \
	$(ENGLISHDIR)/releases/etch/debian-installer/etchnhalf-images.data \
	$(TEMPLDIR)/release_info.wml \
	$(TEMPLDIR)/installer.wml
