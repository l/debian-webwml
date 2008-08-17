# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=international/Swedish
SUBS=
NOGENERICINSTDEP := true

include $(WMLBASE)/Make.lang

$(HTMLDIR)/%.$(LANGUAGE).html: %.$(LANGUAGE).html
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	@echo copying $(@F) to $(HTMLDIR)
	-@install -m 664 -p $(@F) $(HTMLDIR)
ifeq "$(LANGUAGE)" "sv"
	@echo making a link $(@D)/$(*F).html -\> $(@F)
	@ln -sf $(@F) $(@D)/$(*F).html
endif
