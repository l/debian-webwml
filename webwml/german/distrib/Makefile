# This Makefile should need no changes from webwml/english/2.0/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

BASE=..
CUR_DIR=distrib

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
# Do Not modify the following line
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

all: $(HTMLFILES) $(IMGDEST)

include $(BASE)/Make.dep.templ    
include $(BASE)/Make.dep.generic

$(HTMLDIR)/vendors.html.$(LANGUAGE): vendors.wml ../../english/distrib/vendors.CD \
		../../english/distrib/vendors.CD.def $(TEMPLDIR)/template.wml
	wml $(WMLOPTIONS) -o UNDEFu$(LANGUAGECAP):$(WMLOUTFILE) $(WMLPROLOG) $(WMLEPILOG) $(<F)
