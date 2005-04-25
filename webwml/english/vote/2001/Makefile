# This Makefile should need no changes from webwml/english/vote/2001/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2001
SUBS=

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

ifeq "$(LANGUAGE)" "en"
textfiles := vote_0001_results.png vote_0001_results.dot
desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
