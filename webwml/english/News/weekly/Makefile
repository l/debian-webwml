# This Makefile should need no changes from webwml/english/News/weekly/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=News/weekly
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=1999

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.generic
include $(WMLBASE)/Make.dep.templ

# Do Not modify the following line
index.html.$(LANGUAGE): index.wml $(wildcard 1999/1999*.wml) \
     $(wildcard $(ENGLISHSRCDIR)/News/weekly/1999/1999*.wml) \
     $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_news.wml $(TEMPLDIR)/languages.wml
