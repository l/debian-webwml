
# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../../..
CUR_DIR=international/spanish/contrib/making-packages/
SUBS=

include $(WMLBASE)/Make.lang


# Not modify the following line
ifeq ($(LANGUAGE),es)

OFILES:=making-packages.es.ps making-packages.es.pdf
OTHER_FILES:=$(patsubst %,$(HTMLDIR)/%,$(OFILES))

$(HTMLDIR)/making-packages.es.ps: making-packages.es.ps
	install -m 664 -p $< $(HTMLDIR)
$(HTMLDIR)/making-packages.es.pdf: making-packages.es.pdf
	install -m 664 -p $< $(HTMLDIR)

install:: $(OTHER_FILES)
cleandest::
	-rm -f $(HTMLDIR)/{$(OFILES)}


endif

making-packages.es: making-packages.es.ps making-packages.es.pdf

%.pdf: %.ps
	ps2pdf $< $@

%.ps: final-%.ps
	cp $< $@

%.dvi: %.tex
	-latex  $<

%.ps: %.dvi
	dvips -o $@ $<
clean::
	-rm -rf *.bbl *.aux *.toc *.log *.lof *.tmp *.aux *.ps *.pdf

