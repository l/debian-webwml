# This Makefile should need no changes from webwml/english/security/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=events
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=1999

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

#do not modify the following line(s)
index.$(LANGUAGE).html: index.wml $(wildcard 1998/*.wml) $(wildcard 1999/*.wml) \
     $(wildcard $(ENGLISHSRCDIR)/events/1998/*.wml) \
	 $(wildcard $(ENGLISHSRCDIR)/events/1999/*.wml) \
     $(TEMPLDIR)/template.wml $(TEMPLDIR)/footer.wml $(TEMPLDIR)/languages.wml
