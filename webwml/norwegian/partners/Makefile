# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=partners
SUBS=images

include $(WMLBASE)/Make.lang


# there is no reason to translate the file partners-form.txt 
# so don't modify the following
ifeq ($(LANGUAGE),en)
install::
	install -m664 partners-form.txt $(HTMLDIR)
endif
