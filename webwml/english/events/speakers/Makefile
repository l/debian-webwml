# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=events/speakers
SUBS=

NOGENERICDEP := true
GETTEXTFILES += newsevents.mo

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
                        $(ENGLISHSRCDIR)/events/speakers/speakers.data \
                        $(ENGLISHSRCDIR)/events/speakers/speakers.defs \
                        $(GETTEXTDEP)
	$(WML) $(<F)

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/speakers.wml
	$(WML) $(<F)
