# This Makefile should need no changes from webwml/english/events/speakers/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

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
