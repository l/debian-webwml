# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=News/press
# list any subdirectories in the following variable. If a listed directory
# exists, it must contain a Makefile, or make gives an error
SUBS=

GETTEXTFILES += others.mo
LAST_YEAR = 2007

NOGENERICDEP := true
include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
    $(TEMPLDIR)/countries.wml \
    $(GETTEXTDEP) \
    $(ENGLISHDIR)/News/press/press.tags \
    $(ENGLISHDIR)/News/press/$(LAST_YEAR).data
	$(WML) $(<F)

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/countries.wml \
    $(GETTEXTDEP) \
    $(ENGLISHDIR)/News/press/press.tags \
    $(ENGLISHDIR)/News/press/%.data
	$(WML) $(<F)
