# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=devel/website
SUBS=errors

include $(WMLBASE)/Make.lang

working.$(LANGUAGE).html:: $(TEMPLDIR)/toc.wml

ifeq "$(LANGUAGE)" "en"
translation_coordinators.$(LANGUAGE).html : translation_coordinators.wml \
  $(WMLBASE)/../.wmlrc $(WMLBASE)/.wmlrc \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
  $(ENGLISHDIR)/$(CUR_DIR)/tc.data
else
translation_coordinators.$(LANGUAGE).html : translation_coordinators.wml \
  $(WMLBASE)/../.wmlrc $(WMLBASE)/.wmlrc \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
  $(ENGLISHDIR)/$(CUR_DIR)/tc.data $(LOCALEDIR)/others.mo
endif
