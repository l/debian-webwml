# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=.
CUR_DIR=
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=2.0 MailingLists News SPI devel distrib doc events intro logos ports \
security 

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.generic
include $(WMLBASE)/Make.dep.templ

# Do Not modify the following line
index.html.$(LANGUAGE): index.wml $(TEMPLDIR)/mainpage.wml \
		$(wildcard News/1998/1998*.wml) $(wildcard $(ENGLISHSRCDIR)/News/1998/1998*.wml) \
		$(TEMPLDIR)/ctime.wml $(TEMPLDIR)/recent_list.wml $(TEMPLDIR)/languages.wml
	$(WML) index.wml

