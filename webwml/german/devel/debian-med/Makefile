# Makefile for webwml/german/devel/debian-med

WMLBASE=../..
CUR_DIR=devel/debian-med
SUBS=News

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/News/[0-9]*/*.wml)

#packaged.$(LANGUAGE).html: packaged.wml \
#  $(ENGLISHSRCDIR)/devel/debian-med/packaged.tags \
#  $(wildcard $(ENGLISHSRCDIR)/devel/debian-med/packaged/*/*) \
#  $(wildcard $(ENGLISHSRCDIR)/devel/debian-med/packaged-non-free/*/*)
