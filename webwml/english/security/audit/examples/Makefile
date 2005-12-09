# This Makefile should need no changes from webwml/english/security/audit/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=security/audit/examples
SUBS=

GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"
textfiles := test.c test.c.html highlight.css
desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
