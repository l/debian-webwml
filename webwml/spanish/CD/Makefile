# This Makefile should need no changes from webwml/english/CD/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=CD
SUBS=artwork faq http-ftp jigdo-cd mirroring netinst pictures pik releases vendors

NOGENERICDEP := true
include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/cdimage.wml
	$(WML) $(<F)

misc.$(LANGUAGE).html: misc.wml $(TEMPLDIR)/cdimage.wml
	$(WML) $(<F)

install::
	[ -L $(HTMLDIR)/images ] || ln -sf . $(HTMLDIR)/images
