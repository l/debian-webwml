# this is one gross hack :)

LANGUAGE := en
TEMPLDIR := ../../template/debian
HTMLDIR := ../../../../debian.org/News/weekly
WML = wml -q -D CUR_YEAR=$(shell date +%Y) -o UNDEFuEN:$(@F)
YEAR := $(shell date +%Y)

# This Makefile will handle converting all .wml files in this directory
# and all subdirectories to .html files. It does it this way so I don't need
# a new Makefile for each new issue.
WMLFILES = $(shell find . -type f -name \*.wml)
HTMLFILES := $(patsubst %.wml,%.$(LANGUAGE).html,$(WMLFILES))
HTMLDESTFILES := $(patsubst %.wml,$(HTMLDIR)/%.$(LANGUAGE).html,$(WMLFILES))

all: index.$(LANGUAGE).html $(HTMLFILES)

# Need to rebuild the index when anything changes.
index.$(LANGUAGE).html: $(wildcard $(YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(TEMPLDIR)/weeklynews/index.wml \
      ../../../english/News/weekly/CURRENT-ISSUE-IS

# When building the html files we have to change into the right directory
# so wml gets all the relative links right.
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/weeklynews/footer.wml \
	                   $(TEMPLDIR)/weeklynews/header.wml
	cd $(@D) && $(WML) $(notdir $(<)) \
		-DWML_SRC_REALNAME="Joey Hess" -DWML_SRC_USERNAME=joeyh

install: $(HTMLDESTFILES)
	@# Set up current issue symlink. In case you're wondering, the only
	@# reason I use ..../current/issue instead of ...../current is
	@# so it will be 2 directories deep and all the relative symlinks
	@# will still work. Bleargh.
ifeq ($(LANGUAGE),en)
	@test -d $(HTMLDIR)/current || install -d $(HTMLDIR)/current
	@rm -f $(HTMLDIR)/current/issue
	@ln -sf ../$(shell cat ../../../english/News/weekly/CURRENT-ISSUE-IS) $(HTMLDIR)/current/issue
endif


# This is used by the install rule, and I had to hack on it, overriding
# Make.common to allow installation of files into subdirectories.
$(HTMLDIR)/%.$(LANGUAGE).html: %.$(LANGUAGE).html
	test -d $(@D) || install -d $(@D)
	@echo copying $(@F) to $(@D)
	-@cp $(<) $(@D)
ifeq ($(LANGUAGE),en)
	@echo making a link $(@D)/$(*F).html -\> $(@F)
	-@ln -f -s $(@F) $(@D)/$(*F).html
endif

%: force
	@$(MAKE) -f Makefile $@
force: ;
