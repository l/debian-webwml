
# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../../..
CUR_DIR=international/spanish/contrib/presentacion/
SUBS=

include $(WMLBASE)/Make.lang


# Not modify the following line
ifeq ($(LANGUAGE),es)

OFILES:=presentacion.pdf presentacion.html/index.html
OTHER_FILES:=$(patsubst %,$(HTMLDIR)/%,$(OFILES))

$(HTMLDIR)/presentacion.ps: presentacion.ps
	install -m 664 -p $< $(HTMLDIR)
$(HTMLDIR)/presentacion.pdf: presentacion.ps
	install -m 664 $< $(HTMLDIR)
$(HTMLDIR)/presentacion.html/index.html: presentacion.html/index.html
	install -m 664 -p $< $(HTMLDIR)

install:: $(OTHER_FILES)
cleandest::
	-rm -rf $(HTMLDIR)/{$(OFILES)}


endif

all:: presentacion.ps presentacion.pdf presentacion.html/index.html

%.pdf: %.sgml
	debiandoc2latexpdf -l es $<

%.ps: %.sgml
	debiandoc2latexps -l es $<

presentacion.html/index.html: presentacion.sgml
	mkdir presentacion.html
	debiandoc2html -l es $<

clean::
	-rm -rf *.bbl *.aux *.toc *.log *.lof *.tmp *.aux *.ps *.pdf *.html

