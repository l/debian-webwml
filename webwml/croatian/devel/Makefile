# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=devel
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

# Do Not modify the following line
people.$(LANGUAGE).html: people.wml $(TEMPLDIR)/template.wml $(ENGLISHSRCDIR)/devel/people.names

