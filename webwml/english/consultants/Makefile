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

all: $(HTMLFILES) $(IMGDEST)

include $(BASE)/Make.dep.templ    

$(HTMLDIR)/index.html.$(LANGUAGE) : index.wml $(TEMPLDIR)/template.wml \
		../../english/consultants/consultant.data
	wml $(WMLOPTIONS) -o UNDEFu$(LANGUAGECAP):$(WMLOUTFILE) $(WMLPROLOG) $(WMLEPILOG) $(<F)
$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/consultant.wml
	$(WML) $(<F)
