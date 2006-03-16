# This Makefile should need no changes from webwml/english/international/l10n/templates/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=international/l10n/templates
SUBS=

include $(WMLBASE)/Make.lang

clean::
	-rm -rf gen
	-rm -f tmpl.$(LANGUAGE).tmpl

install:: $(patsubst %,$(HTMLDIR)/%,$(HTML_TEMPLATES))
	-rm -rf gen
	-rm -f tmpl.$(LANGUAGE).tmpl
	-rm -f *.html
	-rm -f $(HTMLDIR)/*.html

