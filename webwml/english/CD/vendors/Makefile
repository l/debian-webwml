# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=CD/vendors
SUBS=

GETTEXTFILES += vendors.mo

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en" 
$(ENGLISHSRCDIR)/CD/vendors/vendors.inc: vendors.CD count
	$(ENGLISHSRCDIR)/CD/vendors/count
endif

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/cdimage.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHDIR)/CD/vendors/vendors.CD $(ENGLISHDIR)/CD/vendors/vendors.CD.def \
  $(ENGLISHSRCDIR)/CD/vendors/vendors.inc $(GETTEXTDEP)

# sadly we can't do this nicely inside the file, by referencing the value
# after #use'ing release_info, because we need it to construct the #include
# path, both of which is pass 1 (IPP), and the tag is pass 2 (mp4h)
# besides, it's good to have a makefile dependency as well
tes := $(shell grep "define-tag current_testing_name" $(TEMPLDIR)/release_info.wml | grep -v ^\# | cut -d\< -f2 | cut -d\> -f2)

adding-form.$(LANGUAGE).html: adding-form.wml \
  $(TEMPLDIR)/countries.wml $(GETTEXTDEP) \
  $(ENGLISHDIR)/releases/$(tes)/release.data
	$(WML) $(<F) -D TESTING=$(tes)
