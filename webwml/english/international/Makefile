# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=international
SUBS=Catalan Chinese Croatian Danish German l10n Polish Slovak Swedish

# Note: we cannot use LANGUAGE here since it is defined in Make.lang
# and we cannot move Make.lang up since SUBS is used to define variables
# in Makefile.common, so we are stuck with this crude hack
ifneq (,$(findstring french/,$(CURDIR)))
SUBS += french
endif

ifneq (,$(findstring spanish/,$(CURDIR)))
SUBS += spanish
endif

ifneq (,$(findstring dutch/,$(CURDIR)))
SUBS += dutch
endif

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(ENGLISHSRCDIR)/international/index.data
