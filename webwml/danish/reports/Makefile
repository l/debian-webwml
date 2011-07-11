# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=releases
SUBS=hamm slink potato woody sarge etch lenny squeeze wheezy sid

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/release_info.wml

ifeq "$(LANGUAGE)" "en"
# this stuff creates symlinks for releases
tes := $(shell grep "define-tag current_testing_name" $(TEMPLDIR)/release_info.wml | grep -v ^\# | cut -d\< -f2 | cut -d\> -f2)
rel := $(shell grep "define-tag current_release_name" $(TEMPLDIR)/release_info.wml | grep -v ^\# | cut -d\< -f2 | cut -d\> -f2)
old := $(shell grep "define-tag current_oldstable_name" $(TEMPLDIR)/release_info.wml | grep -v ^\# | cut -d\< -f2 | cut -d\> -f2)

install::
	@[ -d "$(tes)" -a -d "$(rel)" ] || { echo "No $(tes) (testing) or $(rel) (stable) directory in releases."; exit 1; }
	@if [ "`readlink $(HTMLDIR)/oldstable`" != "$(old)" ]; then rm -f $(HTMLDIR)/oldstable; fi
	@if [ "`readlink $(HTMLDIR)/stable`" != "$(rel)" ]; then rm -f $(HTMLDIR)/stable; fi
	@if [ "`readlink $(HTMLDIR)/testing`" != "$(tes)" ]; then rm -f $(HTMLDIR)/testing; fi
	@test -L $(HTMLDIR)/oldstable || ln -sv $(old) $(HTMLDIR)/oldstable
	@test -L $(HTMLDIR)/stable || ln -sv $(rel) $(HTMLDIR)/stable
	@test -L $(HTMLDIR)/testing || ln -sv $(tes) $(HTMLDIR)/testing
endif
