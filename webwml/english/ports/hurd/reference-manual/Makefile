# This Makefile should need no changes from webwml/english/ports/mips/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../../..
CUR_DIR=ports/hurd/reference-manual
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
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
	-install -d $(HTMLDIR)
install:: $(RMDESTFILES)

$(RMDESTFILES): $(RMSOURCE)
	install $(@F) $(HTMLDIR)
