# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=devel
SUBS=website join misc wnpp todo \
 debian-jr debian-med debian-desktop debian-lex \
 debian-nonprofit debian-installer debian-accessibility buildd

include $(WMLBASE)/Make.lang

people.$(LANGUAGE).html: people.wml $(TEMPLDIR)/template.wml \
 $(ENGLISHSRCDIR)/devel/people.names
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml
