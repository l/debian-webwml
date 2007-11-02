# This Makefile should need no changes from webwml/english/security/audit/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=security/audit

all:: dsa
clean::
	-rm ./data/[0-9]*.inc

dsa: make-advisories
	./make-advisories ./data 

SUBS=examples  2002 2003 2004 2005 2006 2007
GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang

.PHONY: dsa
