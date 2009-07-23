# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=international
SUBS=Catalan Chinese Croatian Danish German l10n Polish Swedish

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "fr"
SUBS += french
endif

ifeq "$(LANGUAGE)" "es"
SUBS += spanish
endif

ifeq "$(LANGUAGE)" "nl"
SUBS += dutch
endif

index.$(LANGUAGE).html: index.wml $(ENGLISHSRCDIR)/international/index.data
