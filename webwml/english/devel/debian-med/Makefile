# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=devel/debian-med
SUBS=News

GETTEXTFILES = debian-cdd.mo

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml $(GETTEXTDEP)\
  $(TEMPLDIR)/recent_list.wml $(wildcard News/[0-9]*/*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/News/[0-9]*/*.wml)

#packaged.$(LANGUAGE).html: packaged.wml \
#  $(ENGLISHSRCDIR)/devel/debian-med/packaged.tags \
#  $(wildcard $(ENGLISHSRCDIR)/devel/debian-med/packaged/*/*) \
#  $(wildcard $(ENGLISHSRCDIR)/devel/debian-med/packaged-non-free/*/*)
