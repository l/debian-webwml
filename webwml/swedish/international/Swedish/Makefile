# This Makefile should need no changes from webwml/swedish/international/Swedish/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=international/Swedish
SUBS=
NOGENERICINSTDEP := true

include $(WMLBASE)/Make.lang

$(HTMLDIR)/%.$(LANGUAGE).html: %.$(LANGUAGE).html
	@echo copying $(@F) to $(HTMLDIR)
	-@cp $(@F) $(HTMLDIR)
ifeq "$(LANGUAGE)" "sv"
	@echo making a link $(@D)/$(*F).html -\> $(@F)
	@ln -sf $(@F) $(@D)/$(*F).html
endif
