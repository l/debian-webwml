# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=.
CUR_DIR=
SUBS=banners Bugs MailingLists News Pics consultants devel distrib doc events intro \
international logos mirror misc partners ports releases security vote y2k \
chinese searchtmpl events contrib

include $(WMLBASE)/Make.lang

CUR_YEAR ?= $(shell date +%Y)

# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/mainpage.wml \
		$(wildcard News/$(CUR_YEAR)/[0-9]*.wml) $(wildcard $(ENGLISHSRCDIR)/News/$(CUR_YEAR)/[0-9]*.wml) \
		$(wildcard security/$(CUR_YEAR)/dsa-[0-9]*.wml) $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-[0-9]*.wml) \
		$(TEMPLDIR)/ctime.wml $(TEMPLDIR)/recent_list.wml $(TEMPLDIR)/languages.wml \
		$(ENGLISHSRCDIR)/releases/info
	$(WML) index.wml

install::
	test -L $(HTMLDIR)/intl || ln -sf international $(HTMLDIR)/intl
