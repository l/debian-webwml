# This Makefile should need no changes from
#    webwml/english/security/audit/2007/Makefile
#
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.


WMLBASE=../../..
CUR_DIR=security/audit/2007

all:: ../data/2007.inc

install:: all

../data/2007.inc: 
	$(ENGLISHDIR)/security/audit/make-advisories $(ENGLISHDIR)/security/audit/data

include $(WMLBASE)/Make.lang
