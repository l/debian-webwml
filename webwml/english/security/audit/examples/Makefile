# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=security/audit/examples
SUBS=

GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"
textfiles := test.c test.c.html 
# highlight.css
desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
