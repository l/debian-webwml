# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=.
CUR_DIR=
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=Bugs MailingLists News Pics SPI consultants devel distrib doc events intro \
international logos mirror partners ports releases security vote y2k

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.generic
include $(WMLBASE)/Make.dep.templ

# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/mainpage.wml \
		$(wildcard News/1999/1999*.wml) $(wildcard $(ENGLISHSRCDIR)/News/1999/1999*.wml) \
		$(wildcard security/2000/2000*.wml) $(wildcard $(ENGLISHSRCDIR)/security/2000/2000*.wml) \
		$(TEMPLDIR)/ctime.wml $(TEMPLDIR)/recent_list.wml $(TEMPLDIR)/languages.wml
	$(WML) index.wml

