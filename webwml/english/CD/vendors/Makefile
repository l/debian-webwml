# This Makefile should need no changes from webwml/english/CD/vendors/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=CD/vendors
SUBS=

GETTEXTFILES += vendors.mo

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/cdimage.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHDIR)/CD/vendors/vendors.CD $(ENGLISHDIR)/CD/vendors/vendors.CD.def \
  $(GETTEXTDEP)

tes := $(shell grep "define-tag current_testing_name" $(ENGLISHDIR)/releases/info | grep -v ^\# | cut -d\< -f2 | cut -d\> -f2)

adding-form.$(LANGUAGE).html: adding-form.wml $(ENGLISHDIR)/mirror/countries.data \
  $(TEMPLDIR)/countries.wml $(GETTEXTDEP)
	$(WML) $(<F) -D TESTING=$(tes)
