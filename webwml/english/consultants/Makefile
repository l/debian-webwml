# This Makefile should need no changes from webwml/english/consultants/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

BASE=..
CUR_DIR=consultants

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
# Do Not Modify
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

all: $(HTMLFILES) $(JPGDEST)

$(HTMLDIR)/index.html.$(LANGUAGE) : index.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
	wml $(WMLOPTIONS) -o UNDEFu$(LANGUAGECAP):$(WMLOUTFILE) $(WMLPROLOG) $(WMLEPILOG) $(<F)
$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/consultant.wml $(TEMPLDIR)/languages.wml
	$(WML) $(<F)
$(TEMPLDIR)/consultant.wml: $(TEMPLDIR)/footer.wml
	touch $(TEMPLDIR)/consultant.wml
