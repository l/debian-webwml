# This Makefile should need no changes from webwml/english/misc/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=misc
SUBS=laptops

GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang


merchandise.$(LANGUAGE).html: merchandise.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/url.wml $(ENGLISHSRCDIR)/misc/merchandise.data \
	$(ENGLISHSRCDIR)/misc/merchandise.def $(GETTEXTDEP)

hardware_wanted.$(LANGUAGE).html: hardware_wanted.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/url.wml $(ENGLISHSRCDIR)/misc/hardware_wanted.data \
  $(ENGLISHSRCDIR)/misc/hardware.def $(GETTEXTDEP)

ifeq "$(LANGUAGE)" "en"
$(HTMLDIR)/bsd.license: bsd.license
	install -m 664 -p $(@F) $(HTMLDIR)

install:: $(HTMLDIR)/bsd.license

cleandest::
	rm -f $(HTMLDIR)/bsd.license
endif
