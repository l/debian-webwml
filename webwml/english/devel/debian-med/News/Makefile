# Makefile for webwml/english/devel/debian-med/News

WMLBASE=../../..
CUR_DIR=devel/debian-med/News
# list any subdirectories in the following variable. If a listed directory
# exists, it must contain a Makefile, or make gives an error
YEARS:=$(wildcard [12][0-9][0-9][0-9])
SUBS=$(YEARS)

include $(WMLBASE)/Make.lang


# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/[0-9]*/*.wml)
