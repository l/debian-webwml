# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=devel
SUBS=website debian-jr join misc wnpp

include $(WMLBASE)/Make.lang

people.$(LANGUAGE).html: people.wml $(TEMPLDIR)/template.wml \
 $(ENGLISHSRCDIR)/devel/people.names
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/card.wml $(TEMPLDIR)/template.wml
