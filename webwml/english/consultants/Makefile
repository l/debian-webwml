# This Makefile should need no changes from webwml/english/consultants/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=consultants
SUBS=

NOGENERICDEP := true
GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang

ifeq ($(LANGUAGE),en)
$(ENGLISHSRCDIR)/consultants/consultant.inc: consultant.data
	$(ENGLISHSRCDIR)/consultants/count
endif

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
                        $(ENGLISHSRCDIR)/consultants/consultant.data \
                        $(ENGLISHSRCDIR)/consultants/consultant.inc \
                        $(ENGLISHSRCDIR)/consultants/consultant.defs \
                        $(GETTEXTDEP)
	$(WML) $(<F)

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/consultant.wml
	$(WML) $(<F)
