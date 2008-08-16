# This Makefile should need no changes from webwml/english/CD/netinst/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=CD/netinst
SUBS=

NOGENERICDEP := true

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml $(WMLRCDEP) $(GETTEXTDEP) $(TEMPLDIR)/cdimage.wml
	$(WML) $(<F)

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/release_info.wml $(TEMPLDIR)/installer.wml \
  $(TEMPLDIR)/release_images.wml
