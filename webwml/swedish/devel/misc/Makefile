# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../
CUR_DIR=devel/misc
SUBS=

include $(WMLBASE)/Make.lang


# Do Not modify the following line
index.$(LANGUAGE).html: card.ps

card.ps:  card.dvi
	dvips card.dvi -o card.ps

card.dvi: card.tex bottle.eps
	latex card.tex
