BASE=..
CUR_DIR=devel

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANGUAGE),$(WMLFILES))

# EPILOG=--epilog=weblint
$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/template.wml
	wml -q $(EPILOG) $(<F)

all: $(HTMLFILES)

include $(BASE)/Make.templ.inc

$(HTMLDIR)/people.html.$(LANGUAGE): people.wml $(ENGLISHSRCDIR)/devel/people.names

$(HTMLDIR)/ltcp.html.$(LANGUAGE): ltcp.wml translations-bd.pl

people: people.wml
	wml -q people.wml
