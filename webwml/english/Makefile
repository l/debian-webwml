# Translators only need to change the LANGUAGE variable here.
# It will be passed to all Makefiles below this.
export LANGUAGE=en

BASE=.
HTMLDIR=$(BASE)/../../debian.org
TEMPLDIR=$(BASE)/template/debian
ENGLISHSRCDIR=$(BASE)/../english

# EPILOG=--epilog=weblint
$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/template.wml
	wml -q $(EPILOG) $(<F)

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANGUAGE),$(WMLFILES))

all: $(HTMLFILES)
	( cd 2.0; $(MAKE) )
	( cd MailingLists; $(MAKE) )
	( cd SPI; $(MAKE) )
	( cd devel; $(MAKE) )
	( cd distrib; $(MAKE) )
	( cd doc; $(MAKE) )
	( cd intro; $(MAKE) )
	( cd logos; $(MAKE) )
	( cd ports; $(MAKE) )
	( cd security; $(MAKE) )

include $(BASE)/Make.templ.inc

$(HTMLDIR)/index.html.$(LANGUAGE): index.wml news.wml $(TEMPLDIR)/mainpage.wml $(TEMPLDIR)/ctime.wml
	wml -q index.wml
