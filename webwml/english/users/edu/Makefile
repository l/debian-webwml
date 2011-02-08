# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=users/edu
SUBS=

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml\
	$(TEMPLDIR)/users.wml
	$(WML) $(<F)
