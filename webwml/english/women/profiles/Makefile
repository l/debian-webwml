# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=women/profiles
SUBS=pictures
PROFILES := $(filter-out index.wml, $(wildcard *.wml))
## GETTEXTFILES += others.mo

NOGENERICDEP := true
include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html : index.wml $(WMLRCDEP) $(GETTEXTDEP) \
  $(PROFILES) \
  $(TEMPLDIR)/users_list.wml \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
	$(WML) $(<F)
ifeq "$(LANGUAGE)" "en"
	-$(WMLBASE)/../touch_translations.pl $(CURDIR)/$(<F) $(LANGUAGE)
else
ifneq "$(findstring international,$(CUR_DIR))" ""
	-$(WMLBASE)/../touch_translations.pl $(CURDIR)/$(<F) $(LANGUAGE)
endif
endif

%.$(LANGUAGE).html : %.wml $(WMLRCDEP) $(GETTEXTDEP) \
  $(ENGLISHSRCDIR)/women/profiles/profiles.def \
  $(TEMPLDIR)/faqs.wml \
  $(TEMPLDIR)/profiles.wml \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
	$(WML) $(<F)
ifeq "$(LANGUAGE)" "en"
	-$(WMLBASE)/../touch_translations.pl $(CURDIR)/$(<F) $(LANGUAGE)
else
ifneq "$(findstring international,$(CUR_DIR))" ""
	-$(WMLBASE)/../touch_translations.pl $(CURDIR)/$(<F) $(LANGUAGE)
endif
endif
