# This Makefile should need no changes from webwml/english/CD/http-ftp/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

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
