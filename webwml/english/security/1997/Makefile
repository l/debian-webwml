BASE=../..
CUR_DIR=Security/1997

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

# EPILOG=--epilog=weblint
$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
	wml -q $(EPILOG) $(<F)

# WMLFILES := $(wildcard *.wml)
WMLFILES := $(shell echo *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANGUAGE),$(WMLFILES))

all: $(HTMLFILES)

include $(BASE)/Make.templ.inc

$(HTMLDIR)/index.html.$(LANGUAGE): index.wml $(wildcard 1997*.wml) $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_news.wml
