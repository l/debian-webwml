# This Makefile should need no changes from webwml/english/News/2001/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=News/2001
SUBS=

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml $(wildcard 2001*.wml) \
  $(wildcard $(ENGLISHDIR)/News/2001/2001*.wml)
