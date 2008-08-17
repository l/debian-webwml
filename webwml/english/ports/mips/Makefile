# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=ports/mips
SUBS=

include $(WMLBASE)/Make.lang

$(HTMLFILES): $(ENGLISHSRCDIR)/ports/mips/menu.inc $(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml

index.$(LANGUAGE).html: $(ENGLISHSRCDIR)/ports/mips/menu.inc $(ENGLISHSRCDIR)/ports/mips/people.inc \
	$(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml
