BASE=..
CUR_DIR=News

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

# EPILOG=--epilog=weblint
$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
	wml -q $(EPILOG) $(<F)

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANGUAGE),$(WMLFILES))

all: $(HTMLFILES)
	( cd 1998 ; $(MAKE) )
#	( cd 1997 ; $(MAKE) )

include $(BASE)/Make.templ.inc

$(HTMLDIR)/index.html.$(LANGUAGE): index.wml $(wildcard 1997/1997*.wml) $(wildcard 1998/1998*.wml) $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_news.wml
