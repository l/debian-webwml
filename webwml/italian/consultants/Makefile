# This Makefile should need no changes from webwml/english/consultants/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=consultants
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml ../../english/consultants/consultant.data
	./count
	$(WML) $(<F)
#	wml $(WMLOPTIONS) -o UNDEFu$(LANGUAGECAP):$(WMLOUTFILE) $(WMLPROLOG) $(WMLEPILOG) $(<F)
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/consultant.wml
	$(WML) $(<F)
