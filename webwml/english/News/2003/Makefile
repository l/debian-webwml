# This Makefile should need no changes from webwml/english/News/2003/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=News/2003
SUBS=

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml $(GETTEXTDEP)
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml $(wildcard 2003*.wml) \
  $(wildcard $(ENGLISHDIR)/News/2003/2003*.wml) $(GETTEXTDEP)
