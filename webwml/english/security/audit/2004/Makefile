# This Makefile should need no changes from
#    webwml/english/security/audit/2004/Makefile
#
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.


WMLBASE=../../..
CUR_DIR=security/audit/2004

all:: ../data/2004.inc

install:: all

../data/2004.inc: 
	$(ENGLISHDIR)/security/audit/make-advisories $(ENGLISHDIR)/security/audit/data

include $(WMLBASE)/Make.lang
