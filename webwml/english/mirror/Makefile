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

$(HTMLDIR)/ftpsync: ftpsync
	cp -a ftpsync $(HTMLDIR)
$(HTMLDIR)/ftpsync.conf: ftpsync.conf
	cp -a ftpsync.conf $(HTMLDIR)
$(HTMLDIR)/websync: websync
	cp -a websync $(HTMLDIR)
$(HTMLDIR)/websync.conf: websync.conf
	cp -a websync.conf $(HTMLDIR)
$(HTMLDIR)/identity.pub.master.ftp: identity.pub.master.ftp
	cp -a identity.pub.master.ftp $(HTMLDIR)
$(HTMLDIR)/identity.pub.master.web: identity.pub.master.web
	cp -a identity.pub.master.web $(HTMLDIR)
$(HTMLDIR)/anonftpsync: anonftpsync
	cp -a anonftpsync $(HTMLDIR)
$(HTMLDIR)/anonwebsync: anonwebsync
	cp -a anonwebsync $(HTMLDIR)
