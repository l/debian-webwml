# This Makefile should need no changes from webwml/english/Pics/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

# random hint: for i in ../../english/Pics/*.png ../../english/Pics/debian.jpg ../../english/Pics/logo-50.jpg; do ln -s $i . ; done

WMLBASE=..
CUR_DIR=Pics
SUBS=

include $(WMLBASE)/Make.lang

include pics.conf

debbar.pl := $(ENGLISHDIR)/Pics/debbar.pl
ifneq "$(wildcard debbar.pl)" ""
debbar.pl := ./debbar.pl
endif

debbar := $(debbar.pl)
ifneq "$(FONTFACE)" ""
debbar += -fontface $(FONTFACE)
endif
ifneq "$(FONTSIZE)" ""
debbar += -fontsize $(FONTSIZE)
endif
ifneq "$(FONTTYPE)" ""
debbar += -fonttype $(FONTTYPE)
endif
ifneq "$(FONTREGISTRY)" ""
debbar += -fontregistry $(FONTREGISTRY)
endif
ifneq "$(FONTENCODING)" ""
debbar += -fontencoding $(FONTENCODING)
endif

about.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar) -words $(ABOUT_TEXT) -o $@
devel.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar) -words $(DEVEL_TEXT) -o $@
distrib.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar) -words $(DISTRIB_TEXT) -o $@
news.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar) -words $(NEWS_TEXT) -o $@
search.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar) -words $(SEARCH_TEXT) -o $@
sitemap.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar) -words $(SITEMAP_TEXT) -o $@
support.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar) -words $(SUPPORT_TEXT) -o $@

pics: about.$(LANGUAGE).gif devel.$(LANGUAGE).gif distrib.$(LANGUAGE).gif \
  news.$(LANGUAGE).gif search.$(LANGUAGE).gif sitemap.$(LANGUAGE).gif \
  support.$(LANGUAGE).gif
