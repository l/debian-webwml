BASE=.
HTMLDIR=$(BASE)/../../debian.org
TEMPLDIR=$(BASE)/template/debian
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

# the following line does not work on alpha...
# WMLFILES := $(wildcard *.wml)
# but this hack works :-)
WMLFILES := $(shell echo *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANGUAGE),$(WMLFILES))

# EPILOG=--epilog=weblint
$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
	wml -q $(EPILOG) $(<F)

all: $(HTMLFILES)
	( cd 2.0; $(MAKE) )
	# ( cd MailingLists; $(MAKE) )
	( cd News; $(MAKE) )
	# ( cd SPI; $(MAKE) )
	# ( cd devel; $(MAKE) )
	# ( cd distrib; $(MAKE) )
	# ( cd doc; $(MAKE) )
	( cd intro; $(MAKE) )
	# ( cd logos; $(MAKE) )
	# ( cd ports; $(MAKE) )
	# ( cd security; $(MAKE) )

include $(BASE)/Make.templ.inc

$(HTMLDIR)/index.html.$(LANGUAGE): index.wml $(TEMPLDIR)/mainpage.wml $(TEMPLDIR)/ctime.wml $(TEMPLDIR)/recent_news.wml $(TEMPLDIR)/languages.wml
	wml -q index.wml
