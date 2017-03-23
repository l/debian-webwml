# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=partners
# list any subdirectories in the following variable. If a listed directory
# exists, it must contain a Makefile, or make gives an error
YEARS:=$(wildcard [12][0-9][0-9][0-9])
SUBS=$(YEARS) images

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/index.wml) \
     $(wildcard $(ENGLISHSRCDIR)/partners/$(CUR_YEAR)/index.wml) \
     $(wildcard $(ENGLISHSRCDIR)/partners/$(CUR_YEAR)/images) \
     $(TEMPLDIR)/template.wml \
                        $(ENGLISHSRCDIR)/partners/index.include 


# there is no reason to translate the file partners-form.txt 
# so don't modify the following
ifeq "$(LANGUAGE)" "en"
$(HTMLDIR)/partners-form.txt: partners-form.txt
	install -m 664 -p $< $(HTMLDIR)

install:: $(HTMLDIR)/partners-form.txt
endif
