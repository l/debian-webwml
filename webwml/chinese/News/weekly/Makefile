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
ifeq ($(LANGUAGE),zh)
#INT_HTMLFILES := $(patsubst %.wml,%.$(LANGUAGE).html,$(WMLFILES))
HTMLFILES := $(foreach i, cn tw, \
	$(patsubst %.wml,%.$(LANGUAGE)-$(i).html,$(WMLFILES)))
HTMLDESTFILES := $(foreach i, cn tw, \
	$(patsubst %.wml,$(HTMLDIR)/%.$(LANGUAGE)-$(i).html,$(WMLFILES)))
all:: index.$(LANGUAGE)-cn.html index.$(LANGUAGE)-tw.html $(HTMLFILES)
else
HTMLFILES := $(patsubst %.wml,%.$(LANGUAGE).html,$(WMLFILES))
HTMLDESTFILES := $(patsubst %.wml,$(HTMLDIR)/%.$(LANGUAGE).html,$(WMLFILES))
all:: index.$(LANGUAGE).html $(HTMLFILES)
endif

# When building the html files we have to change into the right directory
# so wml gets all the relative links right.
#%.$(LANGUAGE).html : %.wml $(TEMPLDIR)/weeklynews/footer.wml \

%.$(LANGUAGE)-cn.html %.$(LANGUAGE)-tw.html: \
                           %.wml $(TEMPLDIR)/weeklynews/footer.wml \
	                   $(TEMPLDIR)/weeklynews/header.wml
	cd $(@D) && WMLOPTS="-DWML_SRC_REALNAME=\"Joey Hess\" -DWML_SRC_USERNAME=joeyh" $(WML)

	@echo "Converting $*.zh-cn.html.tmp to $*.zh-cn.html (zh_CN.GB2312)..."
	@$(B5TOGB) < $*.zh-cn.html.tmp > $*.zh-cn.html
	rm -f $*.zh-cn.html.tmp
	@$(TOCN) $*.zh-cn.html

	@echo "Converting $*.zh-tw.html.tmp to $*.zh-tw.html (zh_TW.Big5)..."
	#       @$(U8TOB5) < $*.zh-tw.html > $*.zh-tw.html.tmp
	mv -f $*.zh-tw.html.tmp $*.zh-tw.html
	@$(TOTW) $*.zh-tw.html


install:: $(HTMLDESTFILES)
	@# Set up current issue symlink. In case you're wondering, the only
	@# reason I use ..../current/issue instead of ...../current is
	@# so it will be 2 directories deep and all the relative symlinks
	@# will still work. Bleargh.
ifeq ($(LANGUAGE),en)
	@install -d $(HTMLDIR)/current
	@-rm -f $(HTMLDIR)/current/issue
	-ln -sf ../$(YEAR)/$(shell cat CURRENT-ISSUE-IS) $(HTMLDIR)/current/issue
endif

# This is used by the install rule, and I had to hack on it, overriding
# Make.common to allow installation of files into subdirectories.
$(HTMLDIR)/%.$(LANGUAGE)-cn.html $(HTMLDIR)/%.$(LANGUAGE)-tw.html: \
							%.$(LANGUAGE).html
	install -d $(@D)
	@echo copying $(@F) to $(@D)
	-@cp $(<) $(@D)
ifeq ($(LANGUAGE),en)
	@echo making a link $(@D)/$(*F).html -\> $(@F)
	-@ln -f -s $(@F) $(@D)/$(*F).html
endif

# Have to add to the default clean rule to clean up all the html the
# above target produces.
clean::
	-find . -type f \( -name \*.$(LANGUAGE).html -o \
			   -name \*.$(LANGUAGE)-tw.html -o \
			   -name \*.$(LANGUAGE)-cn.html \) | xargs rm -f

# Need to rebuild the index when anything changes.
#index.$(LANGUAGE).html: $(wildcard $(YEAR)/*/index.wml) \

index.$(LANGUAGE)-cn.html index.$(LANGUAGE)-tw.html: \
					$(wildcard $(YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(TEMPLDIR)/weeklynews/index.wml

# Generate the mail for posting to debian-news. Requires the web page already
# be updated. The mail still requires slight edits.
mail:	
	@cat mail-header
	@lynx -dump  http://www.debian.org/News/weekly/$(YEAR)/$(shell cat CURRENT-ISSUE-IS)/ | \
		perl -pe 's/^\s\s?\s?//'
