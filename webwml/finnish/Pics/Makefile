# This Makefile should need no changes from webwml/english/Pics/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

# random hint: for i in ../../english/Pics/*.png ../../english/Pics/debian.jpg ../../english/Pics/logo-50.jpg; do ln -s $i . ; done

WMLBASE=..
CUR_DIR=Pics
SUBS=

include $(WMLBASE)/Make.lang
include pics_texts.in

debbar.pl := $(ENGLISHDIR)/Pics/debbar.pl

about.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar.pl) -words $(ABOUT_TEXT) -o $@
devel.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar.pl) -words $(DEVEL_TEXT) -o $@
distrib.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar.pl) -words $(DISTRIB_TEXT) -o $@
news.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar.pl) -words $(NEWS_TEXT) -o $@
search.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar.pl) -words $(SEARCH_TEXT) -o $@
sitemap.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar.pl) -words $(SITEMAP_TEXT) -o $@
support.$(LANGUAGE).gif: $(debbar.pl)
	$(debbar.pl) -words $(SUPPORT_TEXT) -o $@

pics: about.$(LANGUAGE).gif devel.$(LANGUAGE).gif distrib.$(LANGUAGE).gif \
  news.$(LANGUAGE).gif search.$(LANGUAGE).gif sitemap.$(LANGUAGE).gif \
  support.$(LANGUAGE).gif
