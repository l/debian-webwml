# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=ports/powerpc/inst
SUBS=

include $(WMLBASE)/Make.lang

$(HTMLFILES): $(ENGLISHSRCDIR)/ports/powerpc/inst/menu.inc \
  $(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml

SGMLFILES := $(wildcard *.sgml)

# TODO: add more boot-floppies/documentation/Makefile magic for translations
%.html/index.$(LANGUAGE).html: %.sgml
	debiandoc2html -l $(LANGUAGE) -c $<

ifeq "$(SGMLFILES)" "yaboot-howto.sgml"
install:: yaboot-howto.html/index.$(LANGUAGE).html
	test -d $(HTMLDIR)/yaboot-howto || install -d -m 2775 $(HTMLDIR)/yaboot-howto
	install -p -m 0664 yaboot-howto.html/* $(HTMLDIR)/yaboot-howto/

clean::
	rm -rf yaboot-howto.html

cleandest::
	rm -rf $(HTMLDIR)/yaboot-howto
endif
