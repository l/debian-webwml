# This Makefile should need no changes from webwml/english/events/2000/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=events/2000
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=expo vatech-if

include $(WMLBASE)/Make.lang


# Do Not modify the following lines
index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*\-*.wml) $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/event.wml
	$(WML) $(<F)
