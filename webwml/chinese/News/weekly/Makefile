# This Makefile had been changed from webwml/english/News/weekly/Makefile
# in order to accommodate both zh-cn and zh-tw.  -- foka, 2000-03-04

# Original notice template:
# ~~~~~~~~~~~~~~~~~~~~~~~~
# This Makefile should need no changes from webwml/english/News/weekly/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=News/weekly

# I have my own special %.$(LANGUAGE).html rule.
NOGENERICDEP := true
include $(WMLBASE)/Make.lang
CUR_YEAR ?= $(shell date +%Y)
WMLOPTIONS += -DWML_SRC_REALNAME="Joey Hess" -DWML_SRC_USERNAME=joeyh

# Ugly hack to handle the "cd" just before wml...
FIX_BIG5 := $(shell pwd)/$(FIX_BIG5)

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
	cd $(@D) && $(WML) $(notdir $(<))

# Special case for Chinese
%.zh-cn.html %.zh-tw.html : %.wml $(TEMPLDIR)/weeklynews/footer.wml \
	                   $(TEMPLDIR)/weeklynews/header.wml \
			   $(TOCN) $(TOTW)
	cd $(@D) && $(WML) $(notdir $(<))

# *.imgdot-1x1-transp.gif are evil!  Get rid of them!
# Must set nullglob or else the following fails - foka, July 2000

	@shopt -s nullglob; \
	for i in *.imgdot-1x1-transp.gif; do \
	    rm -f $$i; \
	    j=`basename $$i .imgdot-1x1-transp.gif` ; \
	    for k in $$j.$(LANGUAGE)-??.html.tmp; do \
		perl -pi -e "s|$$j\\.(?=imgdot-1x1-transp\\.gif)|$(WMLBASE)/Pics/|g" $$k; \
	    done; \
	done

	@echo -n " * Converting: [zh_CN.GB2312], "
	@$(B5TOGB) < $*.zh-cn.html.tmp > $*.zh-cn.html
	@rm -f $*.zh-cn.html.tmp
	@$(TOCN) $*.zh-cn.html

	@echo "[zh_TW.Big5]."
	@mv -f $*.zh-tw.html.tmp $*.zh-tw.html
	@$(TOTW) $*.zh-tw.html

install:: $(HTMLDESTFILES)
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

# Special case for Chinese
$(HTMLDIR)/%.zh-cn.html: %.zh-cn.html
	test -d $(@D) || install -d $(@D)
	@echo copying $(@F) to $(@D)
	-@cp $(<) $(@D)
$(HTMLDIR)/%.zh-tw.html: %.zh-tw.html
	test -d $(@D) || install -d $(@D)
	@echo copying $(@F) to $(@D)
	-@cp $(<) $(@D)

# Have to add to the default clean rule to clean up all the html the
# above target produces.
clean::
	-find . -type f -name \*.$(LANGUAGE).html | xargs rm -f
# Special case for Chinese
	-find . -type f -name \*.$(LANGUAGE)-??.html | xargs rm -f

# Need to rebuild the index when anything changes.
index.$(LANGUAGE).html: $(wildcard $(CUR_YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(CUR_YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(TEMPLDIR)/weeklynews/index.wml \
      ../../../english/News/weekly/CURRENT-ISSUE-IS

# Special case for Chinese
index.zh-cn.html index.zh-tw.html: $(wildcard $(CUR_YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(CUR_YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(TEMPLDIR)/weeklynews/index.wml \
      ../../../english/News/weekly/CURRENT-ISSUE-IS

# Generate the mail for posting to debian-news. Requires the web page already
# be updated.
mail:
	@./makemail.pl
