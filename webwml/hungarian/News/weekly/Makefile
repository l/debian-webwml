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

ifeq ($(LANGUAGE),zh)
# Ugly hack to handle the "cd" just before wml...
FIX_BIG5 := $(shell pwd)/$(FIX_BIG5)
endif

# This Makefile will handle converting all .wml files in this directory
# and all subdirectories to .html files. It does it this way so I don't need
# a new Makefile for each new issue.
#
WMLFILES=$(shell find . -type f -name \*.wml)
PNGFILES=$(shell find . -type f -name \*.png)
PNGDESTFILES := $(patsubst %.png,$(HTMLDIR)/%.png,$(PNGFILES))

ifneq ($(LANGUAGE),zh)
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
	                   $(TEMPLDIR)/weeklynews/header.wml
	cd $(@D) && $(WML) $(notdir $(<))

# Special case for Chinese
%.zh-cn.html %.zh-hk.html %.zh-tw.html : %.wml \
			   $(TEMPLDIR)/weeklynews/footer.wml \
			   $(TEMPLDIR)/weeklynews/header.wml \
			   $(TOCN) $(TOHK) $(TOTW)
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

	@echo -n "[zh_HK.Big5], "
	@mv -f $*.zh-hk.html.tmp $*.zh-hk.html
	@$(TOHK) $*.zh-hk.html

	@echo "[zh_TW.Big5]."
	@mv -f $*.zh-tw.html.tmp $*.zh-tw.html
	@$(TOTW) $*.zh-tw.html

install:: $(HTMLDESTFILES) $(PNGDESTFILES)
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

# Handle images
$(HTMLDIR)/%.png: %.png
	test -d $(@D) || mkdir -p -m g+w $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)

# Special case for Chinese
$(HTMLDIR)/%.zh-cn.html: %.zh-cn.html
	test -d $(@D) || mkdir -p -m g+w $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)
$(HTMLDIR)/%.zh-hk.html: %.zh-hk.html
	test -d $(@D) || mkdir -p -m g+w $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)
$(HTMLDIR)/%.zh-tw.html: %.zh-tw.html
	test -d $(@D) || mkdir -p -m g+w $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)


# Have to add to the default clean rule to clean up all the html the
# above target produces.
clean::
ifeq ($(LANGUAGE),zh)
	-find . -type f -name \*.$(LANGUAGE)-??.html | xargs rm -f
else
	-find . -type f -name \*.$(LANGUAGE).html | xargs rm -f
endif

# Need to rebuild the index when anything changes.
index.$(LANGUAGE).html: $(wildcard $(CUR_YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(CUR_YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
      $(TEMPLDIR)/weeklynews/header.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(TEMPLDIR)/weeklynews/index.wml \
      $(ENGLISHSRCDIR)/$(CUR_DIR)/CURRENT-ISSUE-IS

# Special case for Chinese
index.zh-cn.html index.zh-hk.html index.zh-tw.html: \
      $(wildcard $(CUR_YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(CUR_YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
      $(TEMPLDIR)/weeklynews/header.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(TEMPLDIR)/weeklynews/index.wml \
      $(ENGLISHSRCDIR)/$(CUR_DIR)/CURRENT-ISSUE-IS

# Generate the mail for posting to debian-news. Requires the web page already
# be updated.
mail:
	@./makemail.pl
