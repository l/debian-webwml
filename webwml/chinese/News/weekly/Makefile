# This Makefile had been changed from webwml/english/News/weekly/Makefile
# in order to accommodate both zh-cn and zh-tw.  -- foka, 2000-03-04

# Original notice template:
# ~~~~~~~~~~~~~~~~~~~~~~~~
# This Makefile should need no changes from webwml/english/News/weekly/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

# Get the current year.
YEAR=$(shell date +%Y)

WMLBASE=../..
CUR_DIR=News/weekly

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common
include $(WMLBASE)/Make.dep.templ
# Notice I do not include Make.dep.generic, since I have my own special
# %.$(LANGUAGE).html rule.

# This Makefile will handle converting all .wml files in this directory
# and all subdirectories to .html files. It does it this way so I don't need
# a new Makefile for each new issue.
WMLFILES=$(shell find . -type f -name \*.wml)
ifneq ($(LANGUAGE),zh)
  HTMLFILES := $(patsubst %.wml,%.$(LANGUAGE).html,$(WMLFILES))
  HTMLDESTFILES := $(patsubst %.wml,$(HTMLDIR)/%.$(LANGUAGE).html,$(WMLFILES))
else
  HTMLFILES := $(foreach i, $(SUBLANG), \
	$(patsubst %.wml,%.$(LANGUAGE)-$(i).html,$(WMLFILES)))
  HTMLDESTFILES := $(foreach i, $(SUBLANG), \
	$(patsubst %.wml,$(HTMLDIR)/%.$(LANGUAGE)-$(i).html,$(WMLFILES)))
endif

ifneq ($(LANGUAGE),zh)
all:: index.$(LANGUAGE).html $(HTMLFILES)
else
all:: index.zh-cn.html index.zh-tw.html $(HTMLFILES)
endif

# When building the html files we have to change into the right directory
# so wml gets all the relative links right.
%.$(LANGUAGE).html : %.wml $(TEMPLDIR)/weeklynews/footer.wml \
	                   $(TEMPLDIR)/weeklynews/header.wml
	cd $(@D) && $(WML) $(notdir $(<)) \
		-DWML_SRC_REALNAME="Joey Hess" -DWML_SRC_USERNAME=joeyh

# Special case for Chinese
%.zh-cn.html %.zh-tw.html : %.wml $(TEMPLDIR)/weeklynews/footer.wml \
	                   $(TEMPLDIR)/weeklynews/header.wml \
			   $(TOCN) $(TOTW)
	cd $(@D) && $(WML) $(notdir $(<)) \
		-DWML_SRC_REALNAME="Joey Hess" -DWML_SRC_USERNAME=joeyh \
		&& if [ -f index.imgdot-1x1-transp.gif ]; then \
			mv -f index.imgdot-1x1-transp.gif i.imgdot-1x1-transp.gif; \
		fi

	@if [ "$(notdir $*)" = "index" ]; then \
	    for i in $*.$(LANGUAGE)-??.html.tmp; do \
		perl -pi -e 's/index(?=\.imgdot-1x1-tran)/i/g' $$i; \
	    done; \
	fi

	@echo "Converting $*.zh-cn.html.tmp to $*.zh-cn.html (zh_CN.GB2312)..."
	@$(B5TOGB) < $*.zh-cn.html.tmp > $*.zh-cn.html
	rm -f $*.zh-cn.html.tmp
	@$(TOCN) $*.zh-cn.html

	@echo "Converting $*.zh-tw.html.tmp to $*.zh-tw.html (zh_TW.Big5)..."
	mv -f $*.zh-tw.html.tmp $*.zh-tw.html
	@$(TOTW) $*.zh-tw.html

install:: $(HTMLDESTFILES)
	@# Set up current issue symlink. In case you're wondering, the only
	@# reason I use ..../current/issue instead of ...../current is
	@# so it will be 2 directories deep and all the relative symlinks
	@# will still work. Bleargh.
ifeq ($(LANGUAGE),en)
	@install -d $(HTMLDIR)/current
	@rm -f $(HTMLDIR)/current/issue
	@ln -sf ../$(shell cat ../../../english/News/weekly/CURRENT-ISSUE-IS) $(HTMLDIR)/current/issue
endif

# This is used by the install rule, and I had to hack on it, overriding
# Make.common to allow installation of files into subdirectories.
$(HTMLDIR)/%.$(LANGUAGE).html: %.$(LANGUAGE).html
	install -d $(@D)
	@echo copying $(@F) to $(@D)
	-@cp $(<) $(@D)
ifeq ($(LANGUAGE),en)
	@echo making a link $(@D)/$(*F).html -\> $(@F)
	-@ln -f -s $(@F) $(@D)/$(*F).html
endif

# Special case for Chinese
$(HTMLDIR)/%.zh-cn.html: %.zh-cn.html
	install -d $(@D)
	@echo copying $(@F) to $(@D)
	-@cp $(<) $(@D)
$(HTMLDIR)/%.zh-tw.html: %.zh-tw.html
	install -d $(@D)
	@echo copying $(@F) to $(@D)
	-@cp $(<) $(@D)

# Have to add to the default clean rule to clean up all the html the
# above target produces.
clean::
	-find . -type f -name \*.$(LANGUAGE).html | xargs rm -f

# Need to rebuild the index when anything changes.
index.$(LANGUAGE).html: $(wildcard $(YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(TEMPLDIR)/weeklynews/index.wml \
      ../../../english/News/weekly/CURRENT-ISSUE-IS

# Special case for Chinese
index.zh-cn.html index.zh-tw.html: $(wildcard $(YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(TEMPLDIR)/weeklynews/index.wml \
      ../../../english/News/weekly/CURRENT-ISSUE-IS

# Generate the mail for posting to debian-news. Requires the web page already
# be updated. The mail still requires slight edits.
mail:	
	@cat mail-header
	@lynx -dump http://master.debian.org/www-master/debian.org/News/weekly/2000/6/ | \
       		perl -pe 's/^\s\s?\s?//'
