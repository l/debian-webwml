# This Makefile should need no changes from webwml/english/ports/alpha/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=ports/alpha
SUBS=

include $(WMLBASE)/Make.lang


install:: $(HTMLDIR)/postgresql-noopt.diff.gz

ifeq ($(LANGUAGE),en)
$(HTMLDIR)/postgresql-noopt.diff.gz: postgresql-noopt.diff.gz
	install -m 664 -p postgresql-noopt.diff.gz $(HTMLDIR)
endif

$(HTMLFILES): $(ENGLISHSRCDIR)/ports/alpha/menu.inc $(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml
