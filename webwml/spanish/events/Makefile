# This Makefile should need no changes from webwml/english/events/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=events
YEARS=$(wildcard [12][0-9][0-9][0-9])
SUBS=$(YEARS) weekly press
# note: the materials/ subdirectory isn't in CVS.

include $(WMLBASE)/Make.lang


# Do Not modify the following lines
index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*/*.wml) \
     $(ENGLISHSRCDIR)/events/index.include \
     $(wildcard $(ENGLISHSRCDIR)/events/[0-9]*/*.wml) \
     $(TEMPLDIR)/footer.wml $(TEMPLDIR)/languages.wml
