# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=ports/powerpc/inst
SUBS=

include $(WMLBASE)/Make.lang

$(HTMLFILES): $(ENGLISHSRCDIR)/ports/powerpc/inst/menu.inc \
  $(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml

# TODO: add more boot-floppies/documentation/Makefile magic for translations
ifeq "$(LANGUAGE)" "en"
yaboot-howto.html/index.$(LANGUAGE).html: yaboot-howto.sgml
	debiandoc2html -l $(LANGUAGE) -c $<

install:: yaboot-howto.html/index.$(LANGUAGE).html
	test -d $(HTMLDIR)/yaboot-howto || install -d -m 2775 $(HTMLDIR)/yaboot-howto
	install -p -m 0664 yaboot-howto.html/* $(HTMLDIR)/yaboot-howto/
	cd $(HTMLDIR)/yaboot-howto && for i in *.en.html; do \
		file=$$i; ln -sf $$i $${file%.en.html}.html; done

clean::
	rm -rf yaboot-howto.html

cleandest::
	rm -rf $(HTMLDIR)/yaboot-howto
endif
