# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=vote
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=1999 

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(wildcard 1999/vote*.wml) \
	$(wildcard $(ENGLISHSRCDIR)/Vote/1999/vote*.wml) \
	$(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml $(TEMPLDIR)/languages.wml $(TEMPLDIR)/footer.wml 

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml $(TEMPLDIR)/languages.wml $(TEMPLDIR)/footer.wml
	$(WML) $(<F)
