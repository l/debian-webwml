# This Makefile should need no changes from webwml/french/international/french/dico/data
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

DATAFILES=$(wildcard *.wml)
AUXFILES=$(foreach file,$(basename $(DATAFILES)),$(file).$(LANGUAGE).dic)

WMLBASE=../../../..
CUR_DIR=international/french/dico/data
SUBS=


include $(WMLBASE)/Make.lang
WML = wml $(WMLOPTIONS) -o UNDEFu$(LANGUAGECAP):$(WMLOUTFILE)@g+w -oDICO:$(basename $(WMLOUTFILE)).dic@g+w $(WMLPROLOG) $(WMLEPILOG)

all:: $(AUXFILES)

clean::
	rm -f $(AUXFILES)

%.$(LANGUAGE).dic: %.wml
	$(MAKE) $(basename $^).$(LANGUAGE).html -W $^

