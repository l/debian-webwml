# This Makefile should need no changes from webwml/english/devel/todo/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/todo
SUBS=

include $(WMLBASE)/Make.lang

TODOITEMS = $(wildcard items/[0-9][0-9]*.wml) $(wildcard $(ENGLISHDIR)/$(CUR_DIR)/items/[0-9][0-9]*.wml) 

index.$(LANGUAGE).html: $(TODOITEMS) index.wml $(TEMPLDIR)/minicard.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/todoitem.wml
