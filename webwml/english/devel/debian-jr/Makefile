# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=devel/debian-jr
SUBS=News

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml $(wildcard News/[0-9]*/*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/News/[0-9]*/*.wml)

packaged.$(LANGUAGE).html: packaged.wml \
  $(ENGLISHSRCDIR)/devel/debian-jr/packaged.tags \
  $(wildcard $(ENGLISHSRCDIR)/devel/debian-jr/packaged/*/*) \
  $(wildcard $(ENGLISHSRCDIR)/devel/debian-jr/packaged-non-free/*/*)
