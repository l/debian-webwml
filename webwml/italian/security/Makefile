# This Makefile should need no changes from webwml/english/security/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=security
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=1997 1998 1999 2000 undated

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

index.$(LANGUAGE).html: index.wml $(wildcard 2000/2000*.wml) \
     $(wildcard $(ENGLISHSRCDIR)/security/2000/2000*.wml) \
          $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml 


# install keys.txt
ifeq ($(LANGUAGE),en)
install:: $(HTMLDIR)/keys.txt

$(HTMLDIR)/keys.txt: keys.txt
	install keys.txt $(HTMLDIR)
endif
