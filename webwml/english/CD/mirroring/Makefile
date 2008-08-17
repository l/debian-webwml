# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=CD/mirroring
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml $(WMLRCDEP) $(GETTEXTDEP) $(TEMPLDIR)/cdimage.wml
	$(WML) $(<F)

rsync-mirrors.$(LANGUAGE).html: rsync-mirrors.wml $(TEMPLDIR)/cdimage.wml \
  $(ENGLISHDIR)/CD/mirroring/cdimage_mirrors.list

ifeq "$(LANGUAGE)" "en"
$(ENGLISHDIR)/CD/mirroring/cdimage_mirrors.list: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	$< -m $(word 2,$^) -t cdimages-rsync > $@
endif
