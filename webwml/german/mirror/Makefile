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

# the entries below are only needed in the english directory

#$(HTMLDIR)/ftpsync: ftpsync
#	cp ftpsync $(HTMLDIR)
#$(HTMLDIR)/ftpsync.conf: ftpsync.conf
#	cp ftpsync.conf $(HTMLDIR)
#$(HTMLDIR)/websync: websync
#	cp websync $(HTMLDIR)
#$(HTMLDIR)/websync.conf: websync.conf
#	cp websync.conf $(HTMLDIR)
#$(HTMLDIR)/identity.pub.master.ftp: identity.pub.master.ftp
#	cp identity.pub.master.ftp $(HTMLDIR)
#$(HTMLDIR)/identity.pub.master.web: identity.pub.master.web
#	cp identity.pub.master.web $(HTMLDIR)
#$(HTMLDIR)/anonftpsync: anonftpsync
#	cp anonftpsync $(HTMLDIR)
#$(HTMLDIR)/anonwebsync: anonwebsync
#	cp anonwebsync $(HTMLDIR)
