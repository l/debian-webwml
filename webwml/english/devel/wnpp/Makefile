# This Makefile should need no changes from webwml/english/devel/wnpp/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/wnpp
SUBS=

NOGENERICINSTDEP := true
include $(WMLBASE)/Make.lang

ifneq "$(wildcard wnpp.wml)" ""
WNPP_FILES := being_adopted.$(LANGUAGE).html being_packaged.$(LANGUAGE).html orphaned.$(LANGUAGE).html \
	prospective.$(LANGUAGE).html requested.$(LANGUAGE).html rfa_bymaint.$(LANGUAGE).html \
	rfa_bypackage.$(LANGUAGE).html work_needing.$(LANGUAGE).html
endif

$(HTMLDIR)/%.$(LANGUAGE).html: %.$(LANGUAGE).html
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	@echo copying $*.$(LANGUAGE).html to $(HTMLDIR)
	-@install -m 664 -p $*.$(LANGUAGE).html $(HTMLDIR)
ifeq ($(LANGUAGE),en)
	@echo making a link $(HTMLDIR)/$*.html -\> $*.$(LANGUAGE).html
	@ln -sf $*.$(LANGUAGE).html $(HTMLDIR)/$*.html
endif

# There is no wnpp.XY.html destination. This will be run every time,
# which is what we want
wnpp.$(LANGUAGE).html: wnpp.wml
	wml -q wnpp.wml

$(HTMLDIR)/wnpp.$(LANGUAGE).html: wnpp.$(LANGUAGE).html
	@:

install:: $(WNPP_FILES)
ifneq "$(WNPP_FILES)" ""
	install -m 664 -p $(WNPP_FILES) $(HTMLDIR)
ifeq "$(LANGUAGE)" "en"
	$(foreach file,$(WNPP_FILES),ln -sf $(file) $(HTMLDIR)/$(basename $(basename $(file))).html;)
endif
endif
