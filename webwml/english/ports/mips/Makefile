# This Makefile should need no changes from webwml/english/ports/mips/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=ports/mips
SUBS=

include $(WMLBASE)/Make.lang

$(HTMLFILES): $(ENGLISHSRCDIR)/ports/mips/menu.inc $(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml

index.$(LANGUAGE).html: $(ENGLISHSRCDIR)/ports/mips/menu.inc $(ENGLISHSRCDIR)/ports/mips/people.inc \
	$(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml

cpu.$(LANGUAGE).html: $(ENGLISHSRCDIR)/ports/mips/menu.inc $(ENGLISHSRCDIR)/ports/mips/cpu.data \
	$(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml
