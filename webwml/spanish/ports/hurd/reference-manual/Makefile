# This Makefile should need no changes from webwml/english/ports/mips/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../../..
CUR_DIR=ports/hurd/reference-manual
SUBS=

RELHTMLBASE=../../debian.org
RELTEMPLDIR=../english/template/debian

HTMLDIR=$(WMLBASE)/$(RELHTMLBASE)/$(CUR_DIR)
TEMPLDIR=$(WMLBASE)/$(RELTEMPLDIR)
# Do Not modify the following line
ENGLISHSRCDIR=$(WMLBASE)/../english

RMSOURCE := $(wildcard *.html)
RMDESTFILES := $(patsubst %,$(HTMLDIR)/%,$(RMSOURCE))

all:

install::
	test -d $(HTMLDIR) || mkdir -p -m g+w $(HTMLDIR)
install:: $(RMDESTFILES)

$(RMDESTFILES): $(RMSOURCE)
	install -m664 $(@F) $(HTMLDIR)
clean:
