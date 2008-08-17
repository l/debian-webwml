# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../
CUR_DIR=devel/misc
SUBS=

include $(WMLBASE)/Make.lang

MFILES := card.tex
MISC_FILES := $(patsubst %,$(HTMLDIR)/%,$(MFILES))

install:: $(MISC_FILES)

cleandest::
	rm -f $(HTMLDEST)/{$(MISC_FILES)}

ifeq "$(LANGUAGE)" "en"

index.$(LANGUAGE).html: card.ps.gz

card.ps.gz: card.ps
	gzip  -c card.ps >card.ps.gz

card.ps:  card.dvi
	dvips card.dvi -o card.ps

card.dvi: card.tex bottle.eps
	latex card.tex

# there only needs to be one version of the following so
# the non-english directories shouldn't try to install them
$(HTMLDIR)/card.tex: card.tex
	install -m 664 -p card.tex $(HTMLDIR)

endif
