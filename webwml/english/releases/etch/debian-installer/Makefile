# This Makefile should need no changes from webwml/english/releases/etch/debian-installer/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=releases/etch/debian-installer
SUBS=

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html:: $(ENGLISHDIR)/releases/etch/release.data \
	$(TEMPLDIR)/release_images.wml \
	$(TEMPLDIR)/release_info.wml \
	$(TEMPLDIR)/installer.wml

etchnhalf.$(LANGUAGE).html:: $(ENGLISHDIR)/releases/etch/release.data \
	$(ENGLISHDIR)/releases/etch/debian-installer/etchnhalf-images.data \
	$(TEMPLDIR)/release_info.wml \
	$(TEMPLDIR)/installer.wml
