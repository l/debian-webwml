# This Makefile should need no changes from webwml/english/security/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=security
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=1997 1998 1999 undated

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

index.html.$(LANGUAGE): index.wml $(wildcard 1999/1999*.wml) \
     $(wildcard $(ENGLISHSRCDIR)/security/1999/1999*.wml) \
          $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml 

