# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=CD/http-ftp
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml $(WMLRCDEP) $(GETTEXTDEP) $(TEMPLDIR)/cdimage.wml
	$(WML) $(<F)

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/cdimage.wml \
  $(ENGLISHDIR)/CD/http-ftp/cdimage_mirrors.list \
  $(TEMPLDIR)/release_info.wml $(TEMPLDIR)/release_images.wml

ifeq "$(LANGUAGE)" "en"
$(ENGLISHDIR)/CD/http-ftp/cdimage_mirrors.list: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	$< -m $(word 2,$^) -t cdimages-httpftp > $@
endif
