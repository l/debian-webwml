BASE=..
CUR_DIR=security

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANGUAGE),$(WMLFILES))
JPGSOURCE := $(shell echo *.gif)
JPGDEST := $(patsubst %.gif,$(HTMLDIR)/%.gif,$(JPGSOURCE))

# EPILOG=--epilog=weblint
$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
	wml -q $(EPILOG) $(<F)

all: $(HTMLFILES) $(JPGDEST)

$(HTMLDIR)/%.gif : %.gif
	@cp $< $@

include $(BASE)/Make.templ.inc

