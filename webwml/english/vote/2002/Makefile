# This Makefile should need no changes from webwml/english/vote/2001/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2002
SUBS=platforms
VOTE=$(basename $(wildcard vote_*.wml))

include $(WMLBASE)/Make.lang


$(foreach i, $(VOTE), $(i).$(LANGUAGE).html): %.$(LANGUAGE).html: %.wml \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
  $(TEMPLDIR)/votebar.wml

ifeq "$(LANGUAGE)" "en"
textfiles := tally.txt voters.txt vote_0001_results.png vote_0001_results.dot
desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
