# This Makefile should need no changes from webwml/english/vote/2001/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2003
SUBS=platforms

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

ifeq "$(LANGUAGE)" "en"

textfiles := dpl-debate.log        dpl-discuss.log       leader2003_voters.txt  \
             leader2003_tally.txt  gr_voting_tally.txt   gr_voting_voters.txt   \
             gr_sec415_quorum.err  gr_sec415_quorum.log  gr_sec415_quorum.txt   \
             gr_sec415_tally.txt   gr_sec415_voters.txt                         \
             vote_003_results.png  vote_003_results.dot

desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
