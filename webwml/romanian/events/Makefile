# This Makefile should need no changes from webwml/english/events/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=events
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=1998 1999 2000

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

# Do Not modify the following lines
index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*/*.wml) \
     $(ENGLISHSRCDIR)/events/index.include \
     $(wildcard $(ENGLISHSRCDIR)/events/[0-9]*/*.wml) \
     $(TEMPLDIR)/template.wml $(TEMPLDIR)/footer.wml $(TEMPLDIR)/languages.wml
