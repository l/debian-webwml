# This Makefile should need no changes from webwml/english/releases/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=releases
SUBS=hamm slink potato woody

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/info

ifeq "$(LANGUAGE)" "en"
# this stuff creates symlinks for releases
tes := $(shell grep current_testing_name info | cut -d\< -f2 | cut -d\> -f2)
rel := $(shell grep current_release_name info | cut -d\< -f2 | cut -d\> -f2)

install::
	@if [ -d $(HTMLDIR)/hamm -a ! -L $(HTMLDIR)/2.0 ]; then ln -sv hamm $(HTMLDIR)/2.0; fi
	@if [ -d $(HTMLDIR)/slink -a ! -L $(HTMLDIR)/2.1 ]; then ln -sv slink $(HTMLDIR)/2.1; fi
	@if [ -d $(HTMLDIR)/potato -a ! -L $(HTMLDIR)/2.2 ]; then ln -sv potato $(HTMLDIR)/2.2; fi
	@[ -d "$(tes)" -a -d "$(rel)" ] || { echo "No $(tes) or $(rel) directory in releases."; exit 1; }
	@test -L $(HTMLDIR)/stable || ln -sv $(rel) $(HTMLDIR)/stable
	@test -L $(HTMLDIR)/testing || ln -sv $(tes) $(HTMLDIR)/testing
endif
