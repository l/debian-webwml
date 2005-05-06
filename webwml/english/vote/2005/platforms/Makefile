# This Makefile should need no changes from the one you copied
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../../..
CUR_DIR=vote/2005/platforms
SUBS=

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml

index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml
