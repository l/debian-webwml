# This Makefile should need no changes from webwml/english/News/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=News
# list any subdirectories in the following variable. If a listed directory
# exists, it must contain a Makefile, or make gives an error
YEARS:=$(wildcard [12][0-9][0-9][0-9])
SUBS=$(YEARS) weekly

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.generic
include $(WMLBASE)/Make.dep.templ

# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/$(CUR_YEAR)*.wml) \
     $(wildcard $(ENGLISHSRCDIR)/News/$(CUR_YEAR)/$(CUR_YEAR)*.wml) \
     $(wildcard $(CUR_YEAR)/$(CUR_YEAR)*.title) \
     $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml $(TEMPLDIR)/languages.wml
