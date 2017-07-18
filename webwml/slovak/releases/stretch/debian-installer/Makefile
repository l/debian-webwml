# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=releases/stretch/debian-installer
SUBS=

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html:: $(ENGLISHDIR)/releases/stretch/release.data \
	$(TEMPLDIR)/release_images.wml \
	$(TEMPLDIR)/release_info.wml \
	$(TEMPLDIR)/installer.wml
