# This Makefile should need no changes from webwml/english/News/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=News
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=weekly 1997 1998 1999

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.generic
include $(WMLBASE)/Make.dep.templ

# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(wildcard 1998/1998*.wml) \
     $(wildcard $(ENGLISHSRCDIR)/News/1999/1999*.wml) \
     $(wildcard 1999/1999*.title) \
     $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml $(TEMPLDIR)/languages.wml
