# This Makefile should need no changes from webwml/english/intro/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/debian-jr
SUBS=News

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/News/[0-9]*/*.wml)

packaged.$(LANGUAGE).html: packaged.wml \
  $(ENGLISHSRCDIR)/devel/debian-jr/packaged.tags \
  $(wildcard $(ENGLISHSRCDIR)/devel/debian-jr/packaged/*/*) \
  $(wildcard $(ENGLISHSRCDIR)/devel/debian-jr/packaged-non-free/*/*)
