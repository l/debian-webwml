# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=women/profiles
SUBS=pictures
PROFILES := $(filter-out index.wml, $(wildcard *.wml))
## GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml

index.$(LANGUAGE).html: index.wml $(PROFILES) \
	$(TEMPLDIR)/template.wml $(TEMPLDIR)/users_list.wml \
	$(GETTEXTDEP)
	$(WML) $(<F)

%.$(LANGUAGE).html: %.wml \
	$(ENGLISHSRCDIR)/women/profiles/profiles.def $(TEMPLDIR)/faqs.wml \
	$(TEMPLDIR)/profiles.wml
	$(WML) $(<F)
