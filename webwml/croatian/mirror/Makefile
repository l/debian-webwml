# This Makefile should need no changes from webwml/english/devel/mirror/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=mirror
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

MFILES := ftpsync ftpsync.conf websync websync.conf \
	identity.pub.master.ftp identity.pub.master.web \
	anonftpsync anonwebsync
MIRROR_FILES := $(patsubst %,$(HTMLDIR)/%,$(MFILES))

install:: $(MIRROR_FILES)

cleandest::
	-rm -f $(HTMLDEST)/{$(MIRROR_FILES)}

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

