# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=misc
SUBS=laptops

GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang


merchandise.$(LANGUAGE).html: merchandise.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/url.wml $(ENGLISHSRCDIR)/misc/merchandise.data \
	$(ENGLISHSRCDIR)/misc/merchandise.def $(GETTEXTDEP)

ifeq "$(LANGUAGE)" "en"
$(HTMLDIR)/bsd.license: bsd.license
	install -m 664 -p $(@F) $(HTMLDIR)

install:: $(HTMLDIR)/bsd.license

cleandest::
	rm -f $(HTMLDIR)/bsd.license
endif
