# This Makefile should need no changes from webwml/english/CD/mirroring/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=CD/mirroring
SUBS=

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/cdimage.wml \
  $(ENGLISHDIR)/CD/mirroring/cdimage_mirrors.list

ifeq "$(LANGUAGE)" "en"
$(ENGLISHDIR)/CD/mirroring/cdimage_mirrors.list: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	$< -m $(word 2,$^) -t cdimages-rsync > $@
endif
