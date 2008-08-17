# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=ports/amd64
SUBS=

include $(WMLBASE)/Make.lang

$(HTMLFILES): $(ENGLISHSRCDIR)/ports/amd64/menu.inc $(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml

index.$(LANGUAGE).html: $(ENGLISHSRCDIR)/ports/amd64/menu.inc \
	$(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml \
	$(TEMPLDIR)/release_info.wml
