# This Makefile should need no changes from the one you copied
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../../..
CUR_DIR=vote/2000/leadership_debate
SUBS=

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"
install::
	install -m 664 -p informal.txt transcript.txt $(HTMLDIR)
endif
