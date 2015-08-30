# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=devel/hamradio

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/basic.wml $(GETTEXTDEP)\
  $(TEMPLDIR)/recent_list.wml $(wildcard News/[0-9]*/*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/News/[0-9]*/*.wml)

