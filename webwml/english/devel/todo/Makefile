# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=devel/todo
SUBS=

include $(WMLBASE)/Make.lang

TODOITEMS = $(wildcard items/[0-9][0-9]*.wml) $(wildcard $(ENGLISHDIR)/$(CUR_DIR)/items/[0-9][0-9]*.wml) 

index.$(LANGUAGE).html: $(TODOITEMS) index.wml $(TEMPLDIR)/minicard.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/todoitem.wml
