# This Makefile should need no changes from webwml/english/events/2003/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=events/2003
SUBS=

include $(WMLBASE)/Make.lang


# Do Not modify the following lines
EVENTFILES := $(wildcard [0-9]*\-*.wml)
ICSFILES := $(shell ls [0-9]*\-*.wml | grep -v '-report.wml')
ICSFILES := $(ICSFILES:.wml=.$(LANGUAGE).ics)
DESTICSFILES := $(patsubst %.ics,$(HTMLDIR)/%.ics,$(ICSFILES))

all:: $(ICSFILES)

install:: $(DESTICSFILES)

index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*\-*.wml) $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/event.wml
	$(WML) $(<F)

%.$(LANGUAGE).ics: %.wml $(ENGLISHSRCDIR)/events/make_ics.pl
	$(ENGLISHSRCDIR)/events/make_ics.pl $< $@

$(HTMLDIR)/%.ics: %.ics
	@echo copying $< to $(HTMLDIR)
	-@install -m 644 -p $< $(HTMLDIR)
