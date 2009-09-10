# If this makefile is not generic enough to support a translation,
# please contact debian-www.

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
