# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=events
YEARS=$(wildcard [12][0-9][0-9][0-9])
SUBS=$(YEARS) weekly press speakers
# note: the materials/ subdirectory isn't in CVS.

GETTEXTFILES += newsevents.mo

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*/*.wml) \
     $(ENGLISHSRCDIR)/events/index.include \
     $(wildcard $(ENGLISHSRCDIR)/events/[0-9]*/*.wml) \
     $(TEMPLDIR)/footer.wml $(TEMPLDIR)/languages.wml

talks.$(LANGUAGE).html: index.wml $(ENGLISHSRCDIR)/events/talks.data \
	$(ENGLISHSRCDIR)/events/talks.defs
