# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=security/audit

all:: dsa
install:: all
clean::
	-rm ./data/[0-9]*.inc
	-rm ./data/credits.inc

ifeq "$(wildcard data/*.data)" ""
dsa:
else
dsa: $(ENGLISHDIR)/security/audit/make-advisories

$(ENGLISHDIR)/security/audit/make-advisories: $(wildcard data/*.data)
	$(ENGLISHDIR)/security/audit/make-advisories ./data 
endif

SUBS=examples 2002 2003 2004 2005 2006 2007 2008 2009 2011
GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang

.PHONY: dsa
