# This Makefile should need no changes from
# webwml/english/devel/debian-med/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../../..
CUR_DIR=devel/debian-med/talks/med
SUBS=News

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml

install::
ifeq ($(LANGUAGE),en)
	@echo install MGP
	-@install -m 664 -p *.mgp $(HTMLDIR)
endif
