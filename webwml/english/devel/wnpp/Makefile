# This Makefile should need no changes from webwml/english/devel/wnpp/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/wnpp
SUBS=

NOGENERICINSTDEP := true
WNPP_FILES := being_adopted.html being_packaged.html orphaned.html \
	prospective.html requested.html rfa_bymaint.html \
	rfa_bypackage.html withdrawn.html work_needing.html

include $(WMLBASE)/Make.lang

$(HTMLDIR)/%.$(LANGUAGE).html: %.$(LANGUAGE).html
	@echo copying $*.$(LANGUAGE).html to $(HTMLDIR)
	-@install -m 664 -p $*.$(LANGUAGE).html $(HTMLDIR)
ifeq ($(LANGUAGE),en)
	@echo making a link $(HTMLDIR)/$*.html -\> $*.$(LANGUAGE).html
	@ln -sf $*.$(LANGUAGE).html $(HTMLDIR)/$*.html
endif

# There is no wnpp.en.html destination. This will be run every time,
# which is what we want
ifeq ($(LANGUAGE),en)
wnpp.$(LANGUAGE).html: wnpp.wml
	wml -q wnpp.wml

$(HTMLDIR)/wnpp.$(LANGUAGE).html: wnpp.$(LANGUAGE).html
	@:

install:: $(WNPP_FILES)
	install $(WNPP_FILES) $(HTMLDIR)
endif
