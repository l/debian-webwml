# This Makefile should need no changes from webwml/english/vote/2001/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2004
SUBS=platforms

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

ifeq "$(LANGUAGE)" "en"

textfiles := vote_001.quorum.err vote_001.quorum.log vote_001.quorum.txt \
             vote_002.quorum.err vote_002.quorum.log vote_002.quorum.txt \
             vote_003.quorum.err vote_003.quorum.log vote_003.quorum.txt \
             gr_non_free_results.txt gr_non_free_tally.txt gr_non_free_vote.png \
             gr_non_free_vote_detailed.png gr_non_free_voters.txt \
             leader2004_results.txt leader2004_tally.txt leader2004_vote.png \
             leader2004_vote_detailed.png leader2004_voters.txt
desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
