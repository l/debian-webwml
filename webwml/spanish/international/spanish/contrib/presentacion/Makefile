
# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../../..
CUR_DIR=international/spanish/contrib/presentacion
SUBS=

include $(WMLBASE)/Make.lang


# Not modify the following line
ifeq ($(LANGUAGE),es)

OFILES:=presentacion.ps presentacion.pdf
OTHER_FILES:=$(patsubst %,$(HTMLDIR)/%,$(OFILES))

$(HTMLDIR)/presentacion.ps: presentacion.ps
	install -m 664 -p $< $(HTMLDIR)
$(HTMLDIR)/presentacion.pdf: presentacion.pdf
	install -m 664 -p $< $(HTMLDIR)

install:: $(OTHER_FILES)
cleandest::
	-rm -f $(HTMLDIR)/{$(OFILES)}


endif

presentacion: presentacion.ps presentacion.pdf

%.pdf: %.ps
	ps2pdf $< $@

%.ps: final-%.ps
	cp $< $@

%.dvi: %.tex
	-latex  `echo $< | perl -p -e 's/\..+$$//;'`

%.ps: %.dvi
	dvips -o $@ $<
clean::
	-rm -rf *.bbl *.aux *.toc *.log *.lof *.tmp *.aux *.ps *.pdf

