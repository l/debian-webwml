BASE=..
CUR_DIR=distrib

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

# EPILOG=--epilog=weblint
$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
	wml -q $(EPILOG) $(<F)

all: $(HTMLFILES)

include $(BASE)/Make.templ.inc

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANGUAGE),$(WMLFILES))
