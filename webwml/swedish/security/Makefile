# This Makefile should need no changes from webwml/english/security/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=security
# list any subdirectories in the following variable. If a listed directory
# exists, it must contain a Makefile, or make gives an error
YEARS:=$(wildcard [12][0-9][0-9][0-9])
SUBS=$(YEARS) undated

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/$(CUR_YEAR)*.wml) \
     $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/$(CUR_YEAR)*.wml) \
          $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml 


# install keys.txt
ifeq ($(LANGUAGE),en)
install:: $(HTMLDIR)/keys.txt

$(HTMLDIR)/keys.txt: keys.txt
	install keys.txt $(HTMLDIR)
endif
