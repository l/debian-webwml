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

DLFFSOURCE := $(wildcard debian-l10n-french-faq.html/*.html)
DLFFDESTFILES := $(patsubst %,$(HTMLDIR)/%,$(DLFFSOURCE))
DLFFDESTDIR := $(HTMLDIR)/debian-l10n-french-faq.html

install::
	test -d $(DLFFDESTDIR) || mkdir -p -m g+w $(DLFFDESTDIR)
install:: $(DLFFDESTFILES)

$(DLFFDESTFILES): $(DLFFSOURCE)
	install -m664 $(@F) $(DLFFDESTDIR)

