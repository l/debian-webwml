# This Makefile should need no changes from webwml/english/ports/amd64/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=ports/amd64
SUBS=

include $(WMLBASE)/Make.lang

$(HTMLFILES): $(ENGLISHSRCDIR)/ports/amd64/menu.inc $(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml

index.$(LANGUAGE).html: $(ENGLISHSRCDIR)/ports/amd64/menu.inc \
	$(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml \
	$(TEMPLDIR)/release_info.wml
