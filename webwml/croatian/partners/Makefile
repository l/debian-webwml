# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=partners
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=images

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

# there is no reason to translate the file partners-form.txt 
# so don't modify the following
ifeq ($(LANGUAGE),en)
install::
	install -m664 partners-form.txt $(HTMLDIR)
endif
