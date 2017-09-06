# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=partners
GETTEXTFILES += partners.mo
# list any subdirectories in the following variable. If a listed directory
# exists, it must contain a Makefile, or make gives an error
YEARS:=$(wildcard [12][0-9][0-9][0-9])
SUBS=$(YEARS) images

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/index.wml) \
     $(wildcard $(ENGLISHSRCDIR)/partners/$(CUR_YEAR)/index.wml) \
     $(wildcard $(ENGLISHSRCDIR)/partners/$(CUR_YEAR)/images) \
     $(wildcard $(ENGLISHSRCDIR)/partners/$(CUR_YEAR)/partners.data) \
     $(TEMPLDIR)/template.wml \
     $(ENGLISHSRCDIR)/partners/index.include \
     $(ENGLISHSRCDIR)/partners/partners.def $(GETTEXTDEP)

