# This Makefile should need no changes from webwml/english/security/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

BASE=..
CUR_DIR=security

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
# Do Not modify the following line
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

all: $(HTMLFILES) $(JPGDEST)
	( cd 1997 ; $(MAKE) )
	( cd 1998 ; $(MAKE) )

include $(BASE)/Make.templ.inc

