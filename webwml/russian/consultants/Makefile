# This Makefile should need no changes from webwml/english/consultants/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=consultants
SUBS=

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml $(ENGLISHSRCDIR)/consultants/consultant.data
# You might want to comment out the following two lines if it's a translation
#	$(ENGLISHSRCDIR)/consultants/count
#	$(WML) $(<F)
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/consultant.wml
	$(WML) $(<F)
