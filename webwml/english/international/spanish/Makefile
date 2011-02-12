# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=international/spanish
ifeq "$(LANGUAGE)" "es"
SUBS=contrib
else
SUBS=
endif

#NOGENERICINSTDEP := true

include $(WMLBASE)/Make.lang


ifeq "$(LANGUAGE)" "es"
# NOTE: this part of the makefile only works in the spanish dir!

desarrolladores.$(LANGUAGE).html:: desarrolladores.wml devel.data

ltcp.$(LANGUAGE).html: ltcp.wml ltcp.body

a-releer.es.html a-revisar.es.html a-traducir.es.html en-curso.es.html no-disponible.es.html ok.es.html:: documents-bd.pl 

endif
