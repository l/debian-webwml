# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=consultants
SUBS=

NOGENERICDEP := true
GETTEXTFILES += consultants.mo

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"
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
