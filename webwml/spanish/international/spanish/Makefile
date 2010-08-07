# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=international/spanish
ifeq "$(LANGUAGE)" "es"
SUBS=contrib
else
SUBS=
endif

NOGENERICINSTDEP := true

include $(WMLBASE)/Make.lang

desarrolladores.$(LANGUAGE).html: desarrolladores.wml spanish/devel.data

# This is old code to publish information and is disabled:
#
#$(HTMLDIR)/%.$(LANGUAGE).html: %.$(LANGUAGE).html
#	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
#	@echo copying $(@F) to $(HTMLDIR)
#	-@install -m 664 -p $(@F) $(HTMLDIR)
#ifeq "$(LANGUAGE)" "es"
#	@echo making a link $(@D)/$(*F).html -\> $(@F)
#	@ln -sf $(@F) $(@D)/$(*F).html
#endif

ifeq "$(LANGUAGE)" "es"
# NOTE: this part of the makefile only works in the spanish dir!
ltcp.es.html:: ltcp.body

a-releer.es.html a-revisar.es.html a-traducir.es.html en-curso.es.html no-disponible.es.html ok.es.html:: documents-bd.pl 

#www-a-revisar.es.html www-nok.es.html www-ok.es.html www.es.html: FORCE

#FORCE:
endif
