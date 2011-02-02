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
uns := sid

install::
	@if [ -d $(HTMLDIR)/hamm -a ! -L $(HTMLDIR)/2.0 ]; then ln -sv hamm $(HTMLDIR)/2.0; fi
	@if [ -d $(HTMLDIR)/slink -a ! -L $(HTMLDIR)/2.1 ]; then ln -sv slink $(HTMLDIR)/2.1; fi
	@if [ -d $(HTMLDIR)/potato -a ! -L $(HTMLDIR)/2.2 ]; then ln -sv potato $(HTMLDIR)/2.2; fi
	@if [ -d $(HTMLDIR)/woody -a ! -L $(HTMLDIR)/3.0 ]; then ln -sv woody $(HTMLDIR)/3.0; fi
	@if [ -d $(HTMLDIR)/sarge -a ! -L $(HTMLDIR)/3.1 ]; then ln -sv sarge $(HTMLDIR)/3.1; fi
	@if [ -d $(HTMLDIR)/etch -a ! -L $(HTMLDIR)/4.0 ]; then ln -sv etch $(HTMLDIR)/4.0; fi
	@if [ -d $(HTMLDIR)/lenny -a ! -L $(HTMLDIR)/5.0 ]; then ln -sv lenny $(HTMLDIR)/5.0; fi
	@[ -d "$(tes)" -a -d "$(rel)" ] || { echo "No $(tes) (testing) or $(rel) (stable) directory in releases."; exit 1; }
	@if [ "`readlink $(HTMLDIR)/oldstable`" != "$(old)" ]; then rm -f $(HTMLDIR)/oldstable; fi
	@if [ "`readlink $(HTMLDIR)/stable`" != "$(rel)" ]; then rm -f $(HTMLDIR)/stable; fi
	@if [ "`readlink $(HTMLDIR)/testing`" != "$(tes)" ]; then rm -f $(HTMLDIR)/testing; fi
	@if [ "`readlink $(HTMLDIR)/unstable`" != "$(uns)" ]; then rm -f $(HTMLDIR)/unstable; fi
	@test -L $(HTMLDIR)/oldstable || ln -sv $(old) $(HTMLDIR)/oldstable
	@test -L $(HTMLDIR)/stable || ln -sv $(rel) $(HTMLDIR)/stable
	@test -L $(HTMLDIR)/testing || ln -sv $(tes) $(HTMLDIR)/testing
	@test -L $(HTMLDIR)/unstable || ln -sv $(uns) $(HTMLDIR)/unstable
endif
