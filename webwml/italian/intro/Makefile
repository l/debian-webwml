# Translators should only need to change the LANG variable
LANG=it

BASE=..
CUR_DIR=intro

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
ENGLISHSRCDIR=$(BASE)/../english

# EPILOG=--epilog=weblint
$(HTMLDIR)/%.html.$(LANG) : %.wml $(TEMPLDIR)/template.wml
	wml -q $(EPILOG) $(<F)

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANG),$(WMLFILES))

all: $(HTMLFILES)

include $(BASE)/Make.templ.inc
