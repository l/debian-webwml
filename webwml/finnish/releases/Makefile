# This Makefile should need no changes from webwml/english/releases/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=releases
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=hamm slink potato

include $(WMLBASE)/Make.lang

# unfortunately, I have to force this since it checks whether directories exist
index.$(LANGUAGE).html: FORCE

FORCE:
