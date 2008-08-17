# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=security/key-rollover
SUBS=

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(ENGLISHSRCDIR)/security/key-rollover/index.wml
	$(WML) $(<F)

notvuln.$(LANGUAGE).html: notvuln.wml $(ENGLISHSRCDIR)/security/key-rollover/notvuln.wml
	$(WML) $(<F)
