# This Makefile should need no changes from
#    webwml/english/security/audit/2005/Makefile
#
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.


WMLBASE=../../..
CUR_DIR=security/audit/2005

all:: ../data/2005.inc index.en.html
install:: all

../data/2005.inc:  ../data/2005.data
	$(ENGLISHDIR)/security/audit/make-advisories $(ENGLISHDIR)/security/audit/data

index.en.html: index.wml  ../data/2005.inc ../data/2005.data
	$(WML) $(<F) 

include $(WMLBASE)/Make.lang
