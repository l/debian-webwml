# This Makefile should need no changes from webwml/french/international/french/dico
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

DATAFILES=$(wildcard data/*.wml)
AUXFILES=$(foreach file,$(basename $(DATAFILES)),$(file).$(LANGUAGE).dic)

WMLBASE=../../..
CUR_DIR=international/french/dico
SUBS=data

include $(WMLBASE)/Make.lang

data/%.$(LANGUAGE).dic: data/%.wml
	$(MAKE) -C data

index.$(LANGUAGE).html: $(AUXFILES)


