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
	-@cp $*.$(LANGUAGE).html $(HTMLDIR)
ifeq ($(LANGUAGE),en)
	@echo making a link $(HTMLDIR)/$*.html -\> $*.$(LANGUAGE).html
	@ln -sf $*.$(LANGUAGE).html $(HTMLDIR)/$*.html
endif

# There is no wnpp.en.html destination. This will be run every time,
# which is what we want
wnpp.$(LANGUAGE).html: wnpp.wml
	wml -q wnpp.wml

$(HTMLDIR)/wnpp.$(LANGUAGE).html: wnpp.$(LANGUAGE).html
	@:

install:: $(WNPP_FILES)
	install being_adopted.html $(HTMLDIR)/being_adopted.sv.html
	install being_packaged.html $(HTMLDIR)/being_packaged.sv.html
	install orphaned.html $(HTMLDIR)/orphaned.sv.html
	install prospective.html $(HTMLDIR)/prospective.sv.html
	install requested.html $(HTMLDIR)/requested.sv.html
	install rfa_bymaint.html $(HTMLDIR)/rfa_bymaint.sv.html
	install rfa_bypackage.html $(HTMLDIR)/rfa_bypackage.sv.html
	install withdrawn.html $(HTMLDIR)/withdrawn.sv.html
	install work_needing.html $(HTMLDIR)/work_needing.sv.html
