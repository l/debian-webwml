# Top-level makefile for building cdimage.debian.org web site.
# This is owned by debian-cd and debian-www teams.
# Nothing in here should require any modification.

TEMPLDIR := ../webwml/english/template/debian
TEMPLATES := $(wildcard $(TEMPLDIR)/*.wml) $(wildcard template/*.wml)

HTMLDIR = /org/cdimage.debian.org/www/

WML = wml -q -I. -I $(dir $(TEMPLDIR)) -D CUR_YEAR=$(shell date +%Y) -o UNDEFuEN:$(@F)@g+w

WMLFILES = $(wildcard *.wml)
HTMLFILES = $(patsubst %.wml,%.html,$(WMLFILES))
HTMLDESTFILES = $(patsubst %.wml,$(HTMLDIR)/%.html,$(WMLFILES))

all: $(HTMLFILES)

%.html: %.wml template/cdimage.wml .wmlrc
	$(WML) $(<F)

template/cdimage.wml: $(TEMPLDIR)/basic.wml $(TEMPLDIR)/languages.wml
	touch $@

install::
	test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
install:: $(HTMLDESTFILES)

$(HTMLDIR)/%.html: %.html
	@echo copying $(@F) to $(HTMLDIR)
	-@install -m 664 -p $(@F) $(HTMLDIR)

clean:
	rm -f *.html

.SUFFIXES:
.PHONY: all install clean
