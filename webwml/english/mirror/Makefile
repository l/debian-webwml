# This Makefile should need no changes from webwml/english/devel/mirror/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

BASE=..
CUR_DIR=mirror

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
# Do Not modify the following line
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

MFILES := ftpsync ftpsync.conf websync websync.conf \
	identity.pub.master.ftp identity.pub.master.web \
	anonftpsync anonwebsync
MIRROR_FILES := $(patsubst %,$(HTMLDIR)/%,$(MFILES))

all: $(HTMLFILES) $(JPGDEST) $(MIRROR_FILES)

include $(BASE)/Make.templ.inc

$(HTMLDIR)/ftpsync: ftpsync
	cp ftpsync $(HTMLDIR)
$(HTMLDIR)/ftpsync.conf: ftpsync.conf
	cp ftpsync.conf $(HTMLDIR)
$(HTMLDIR)/websync: websync
	cp websync $(HTMLDIR)
$(HTMLDIR)/websync.conf: websync.conf
	cp websync.conf $(HTMLDIR)
$(HTMLDIR)/identity.pub.master.ftp: identity.pub.master.ftp
	cp identity.pub.master.ftp $(HTMLDIR)
$(HTMLDIR)/identity.pub.master.web: identity.pub.master.web
	cp identity.pub.master.web $(HTMLDIR)
$(HTMLDIR)/anonftpsync: anonftpsync
	cp anonftpsync $(HTMLDIR)
$(HTMLDIR)/anonwebsync: anonwebsync
	cp anonwebsync $(HTMLDIR)
