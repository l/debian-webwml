# This Makefile should need no changes from webwml/english/News/weekly/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=News/weekly

# I have my own special %.$(LANGUAGE).html rule.
NOGENERICDEP := true
include $(WMLBASE)/Make.lang
CUR_YEAR ?= $(shell date +%Y)
#WMLOPTIONS += -DWML_SRC_REALNAME="Joey Hess" -DWML_SRC_USERNAME=joeyh

# This Makefile will handle converting all .wml files in this directory
# and all subdirectories to .html files. It does it this way so I don't need
# a new Makefile for each new issue.
WMLFILES=$(shell find . -type f -name \*.wml)
HTMLFILES := $(patsubst %.wml,%.$(LANGUAGE).html,$(WMLFILES))
HTMLDESTFILES := $(patsubst %.wml,$(HTMLDIR)/%.$(LANGUAGE).html,$(WMLFILES))
all:: index.$(LANGUAGE).html $(HTMLFILES)

# When building the html files we have to change into the right directory
# so wml gets all the relative links right.
%.$(LANGUAGE).html : %.wml $(TEMPLDIR)/weeklynews/footer.wml \
	                   $(TEMPLDIR)/weeklynews/header.wml
	cd $(@D) && $(WML) $(notdir $(<))

install:: $(HTMLDESTFILES)
	@# Set up current issue symlink. In case you're wondering, the only
	@# reason I use ..../current/issue instead of ...../current is
	@# so it will be 2 directories deep and all the relative symlinks
	@# will still work. Bleargh.
ifeq ($(LANGUAGE),en)
	@test -d $(HTMLDIR)/current || mkdir -p -m g+w $(HTMLDIR)/current
	@rm -f $(HTMLDIR)/current/issue
	@ln -sf ../$(shell cat ../../../english/News/weekly/CURRENT-ISSUE-IS) $(HTMLDIR)/current/issue
endif

# This is used by the install rule, and I had to hack on it, overriding
# Make.common to allow installation of files into subdirectories.
$(HTMLDIR)/%.$(LANGUAGE).html: %.$(LANGUAGE).html
	test -d $(@D) || mkdir -p -m g+w $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)
ifeq ($(LANGUAGE),en)
	@echo making a link $(@D)/$(*F).html -\> $(@F)
	-@ln -f -s $(@F) $(@D)/$(*F).html
endif

# Have to add to the default clean rule to clean up all the html the
# above target produces.
clean::
	-find . -type f -name \*.$(LANGUAGE).html | xargs rm -f

# Need to rebuild the index when anything changes.
index.$(LANGUAGE).html: $(wildcard $(CUR_YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(CUR_YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(TEMPLDIR)/weeklynews/index.wml \
      ../../../english/News/weekly/CURRENT-ISSUE-IS

# Generate the mail for posting to debian-news. Requires the web page already
# be updated.
mail:
	@./makemail.pl
