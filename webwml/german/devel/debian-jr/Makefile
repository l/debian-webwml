# This Makefile should need no changes from webwml/english/intro/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/debian-jr
SUBS=News

include $(WMLBASE)/Make.lang

packaged.$(LANGUAGE).html: packaged.wml \
  $(ENGLISHSRCDIR)/devel/debian-jr/lists.tmpl \
  $(ENGLISHSRCDIR)/devel/debian-jr/packaged.data \
  $(ENGLISHSRCDIR)/devel/debian-jr/packaged-non-free.data
