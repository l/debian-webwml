# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=international/french
SUBS=

include $(WMLBASE)/Make.lang


# Do Not modify the following line

$(HTMLFILES): documents-bd.pl current_status.pl

# ask to install the debian-l10-french-faq files

$(HTMLDIR)/debian-l10n-french-faq.html:debian-l10n-french-faq.html
	test -d $(HTMLDIR)/debian-l10-french-faq.html \
	  || mkdir -p -m g+w $(HTMLDIR)/debian-l10-french-faq

$(HTMLDIR)/debian-l10n-french-faq.html/%:debian-l10n-french-faq.html/%

install:: $(patsubst %,$(HTMLDIR)/%,$(wildcard debian-l10-french-faq.html))
