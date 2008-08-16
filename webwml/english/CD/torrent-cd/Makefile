# This Makefile should need no changes from webwml/english/CD/torrent-cd/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=CD/torrent-cd
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml $(WMLRCDEP) $(GETTEXTDEP) $(TEMPLDIR)/cdimage.wml
	$(WML) $(<F)

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/cdimage.wml \
	$(TEMPLDIR)/installer.wml $(TEMPLDIR)/toc.wml \
	$(TEMPLDIR)/release_info.wml \
	$(ENGLISHSRCDIR)/devel/debian-installer/images.data \
	$(TEMPLDIR)/release_images.wml
