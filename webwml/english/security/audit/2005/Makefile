# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=security/audit/2005

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"
$(ENGLISHSRCDIR)/security/audit/data/2005.inc: $(ENGLISHSRCDIR)/security/audit/data/2005.data
	$(ENGLISHSRCDIR)/security/audit/make-advisories $(ENGLISHSRCDIR)/security/audit/data
endif

index.$(LANGUAGE).html: index.wml \
  $(ENGLISHSRCDIR)/security/audit/data/2005.inc \
  $(ENGLISHSRCDIR)/security/audit/data/2005.data
