# Translators should only need to change the LANG variable
LANG=en

BASE=.
HTMLDIR=$(BASE)/../../debian.org
TEMPLDIR=$(BASE)/template/debian
ENGLISHSRCDIR=$(BASE)/../english

# EPILOG=--epilog=weblint
$(HTMLDIR)/%.html.$(LANG) : %.wml $(TEMPLDIR)/template.wml
	wml -q $(EPILOG) $(<F)

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANG),$(WMLFILES))

all: $(HTMLFILES)
	( cd 2.0; make )
	( cd MailingLists; make )
	( cd SPI; make )
	( cd devel; make )
	( cd distrib; make )
	( cd doc; make )
	( cd intro; make )
	( cd logos; make )
	( cd ports; make )
	( cd security; make )

include $(BASE)/Make.templ.inc

$(HTMLDIR)/index.html.$(LANG): index.wml news.wml $(TEMPLDIR)/mainpage.wml $(TEMPLDIR)/ctime.wml
	wml -q index.wml
