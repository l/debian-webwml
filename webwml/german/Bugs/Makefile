# This Makefile should need no changes from webwml/english/Bugs/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=Bugs
SUBS=

include $(WMLBASE)/Make.lang

$(HTMLFILES): otherpages.inc footer.inc

# this needs to be forced, because the pseudo-packages.description list
# may change any time
pseudo-packages.$(LANGUAGE).html: FORCE

FORCE:
