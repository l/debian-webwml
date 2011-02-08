# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=users/org
SUBS=

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml\
	$(TEMPLDIR)/users.wml
	$(WML) $(<F)
