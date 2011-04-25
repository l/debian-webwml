# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=News/weekly

GETTEXTFILES += newsevents.mo

# we have different %.$(LANGUAGE).html and HTMLDIR/%.$(LANGUAGE).html rules here
NOGENERICDEP := true
NOGENERICINSTDEP := true
include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "ja"
ABS_DIR = $(CURDIR)
endif

# This Makefile will handle converting all .wml files in this directory
# and all subdirectories to .html files. It does it this way so
# a new Makefile isn't needed for each new issue.

WMLFILES=$(shell find . -type f -name \*.wml)
PNGFILES=$(shell find . -type f -name \*.png)
PNGDESTFILES := $(patsubst %.png,$(HTMLDIR)/%.png,$(PNGFILES))

ifneq "$(LANGUAGE)" "zh"
  HTMLFILES := $(patsubst %.wml,%.$(LANGUAGE).html,$(WMLFILES))
  HTMLDESTFILES := $(patsubst %.wml,$(HTMLDIR)/%.$(LANGUAGE).html,$(WMLFILES))
  all:: index.$(LANGUAGE).html $(HTMLFILES)
else
  HTMLFILES := $(foreach i, $(SUBLANG), \
       $(patsubst %.wml,%.$(LANGUAGE)-$(i).html,$(WMLFILES)))
  HTMLDESTFILES := $(foreach i, $(SUBLANG), \
       $(patsubst %.wml,$(HTMLDIR)/%.$(LANGUAGE)-$(i).html,$(WMLFILES)))
  all:: index.zh-cn.html index.zh-hk.html index.zh-tw.html $(HTMLFILES)
endif

# When building the html files we have to change into the right directory
# so wml gets all the relative links right.
%.$(LANGUAGE).html : %.wml $(TEMPLDIR)/weeklynews/footer.wml \
	                   $(TEMPLDIR)/weeklynews/header.wml $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "ja"
	cd $(@D) && $(subst ../../convert,$(ABS_DIR)/../../convert,$(WML)) $(notdir $(<))
else
ifeq "$(LANGUAGE)" "pl"
	cd $(@D) && $(subst ../../znaczki.sh,$(CURDIR)/../../znaczki.sh,$(WML)) $(notdir $(<))
else
	cd $(@D) && $(WML) $(notdir $(<))
endif
endif

install:: $(HTMLDESTFILES) $(PNGDESTFILES)
ifeq "$(LANGUAGE)" "en"
# Set up current issue symlink. In case you're wondering, the only
# reason we use ..../current/issue instead of ...../current is
# so it will be 2 directories deep and all the relative symlinks
# will still work. Bleargh.
	@test -d $(HTMLDIR)/current || mkdir -p -m g+w $(HTMLDIR)/current
	@rm -f $(HTMLDIR)/current/issue
	@ln -sf ../$(shell cat ../../../english/News/weekly/CURRENT-ISSUE-IS) $(HTMLDIR)/current/issue
endif

# This is used by the install rule, and I had to hack on it, overriding
# Make.common to allow installation of files into subdirectories.
$(HTMLDIR)/%.$(LANGUAGE).html: %.$(LANGUAGE).html
	@test -d $(@D) || mkdir -m g+w -p $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)
ifeq "$(LANGUAGE)" "en"
	@echo making a link $(@D)/$(*F).html -\> $(@F)
	@ln -sf $(@F) $(@D)/$(*F).html
endif

# Handle images
$(HTMLDIR)/%.png: %.png
	@test -d $(@D) || mkdir -m g+w -p $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)

# Have to add to the default clean rule to clean up all the html the
# above target produces.
clean::
ifeq "$(LANGUAGE)" "ja"
	-find . -type f -name \*.$(LANGUAGE).html.tmp | xargs rm -f
endif
	-find . -type f -name \*.$(LANGUAGE).html | xargs rm -f

# Need to rebuild the index when anything changes.
index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(CUR_YEAR)/*/index.wml) \
      $(ENGLISHSRCDIR)/$(CUR_DIR)/CURRENT-ISSUE-IS \
      $(TEMPLDIR)/projectnews/header.wml \
      $(TEMPLDIR)/projectnews/index.wml \
      $(TEMPLDIR)/projectnews/footer.wml \
      $(TEMPLDIR)/weeklynews/header.wml \
      $(TEMPLDIR)/weeklynews/index.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(GETTEXTDEP)

# per-year indices need to be rebuilt, too.
# this code works around a small bug in make's $(wildcard) function, too
[0-9]*/index.$(LANGUAGE).html: %/index.$(LANGUAGE).html: \
	$(shell find $* -name index.wml) \
        $(wildcard $(ENGLISHSRCDIR)/News/weekly/$*/*/index.wml) \
	$(TEMPLDIR)/projectnews/header.wml \
        $(TEMPLDIR)/projectnews/index.wml \
        $(TEMPLDIR)/projectnews/footer.wml \
        $(TEMPLDIR)/weeklynews/header.wml \
        $(TEMPLDIR)/weeklynews/index.wml \
        $(TEMPLDIR)/weeklynews/footer.wml $(GETTEXTDEP)

CURRENT_ISSUE=$(shell cat $(ENGLISHSRCDIR)/$(CUR_DIR)/CURRENT-ISSUE-IS)/index.wml
DWN_CURRENT=$(shell test -f $(CURRENT_ISSUE) && echo "yes" || echo)

ifeq "$(DWN_CURRENT)" "yes"

export LANGUAGE ENGLISHSRCDIR CUR_DIR
dwn.$(LANGUAGE).rdf:
	$(ENGLISHSRCDIR)/$(CUR_DIR)/dwn-to-rdf.pl

all:: dwn.$(LANGUAGE).rdf
install:: $(HTMLDIR)/dwn.$(LANGUAGE).rdf

clean::
	rm -f dwn.$(LANGUAGE).rdf

$(HTMLDIR)/dwn.$(LANGUAGE).rdf: $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)

.PHONY:	dwn.$(LANGUAGE).rdf
endif

