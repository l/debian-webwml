# This Makefile should need no changes from webwml/english/ports/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

BASE=..
CUR_DIR=ports

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
# Do Not modify the following line
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

# Comment out any lines for which the directory doesn't exist.
# The '#' should be after the <tab> or the following lines won't
# execute with some versions of make
all: $(HTMLFILES) $(IMGDEST)
	( cd sparc; $(MAKE) )
	( cd alpha; $(MAKE) )
	( cd arm; $(MAKE) )
	( cd powerpc; $(MAKE) )

include $(BASE)/Make.dep.templ    
include $(BASE)/Make.dep.generic
