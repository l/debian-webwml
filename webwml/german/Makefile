# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

BASE=.
HTMLDIR=$(BASE)/../../debian.org
TEMPLDIR=$(BASE)/template/debian
# Do Not modify the following line
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang


# Comment out any lines for which the directory doesn't exist.
# The '#' should be after the <tab> or the following lines won't
# execute with some versions of make
all: $(HTMLFILES) $(IMGDEST)
	( cd 2.0; $(MAKE) )
	( cd MailingLists; $(MAKE) )
	( cd News; $(MAKE) )
	( cd SPI; $(MAKE) )
	( cd devel; $(MAKE) )
	( cd distrib; $(MAKE) )
	( cd doc; $(MAKE) )
	( cd intro; $(MAKE) )
	( cd logos; $(MAKE) )
	( cd ports; $(MAKE) )
	( cd security; $(MAKE) )
	( cd events; $(MAKE) )

include $(BASE)/Make.dep.generic
include $(BASE)/Make.dep.templ

# Do Not modify the following line
$(HTMLDIR)/index.html.$(LANGUAGE): index.wml $(TEMPLDIR)/mainpage.wml \
		$(wildcard News/1998/1998*.wml) $(wildcard $(ENGLISHSRCDIR)/News/1998/1998*.wml) \
		$(TEMPLDIR)/ctime.wml $(TEMPLDIR)/recent_list.wml $(TEMPLDIR)/languages.wml
	$(WML) index.wml

