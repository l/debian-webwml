# This Makefile should need no changes from webwml/english/vote/2001/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2005
SUBS=platforms

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

ifeq "$(LANGUAGE)" "en"

textfiles := vote_001.quorum.err vote_001.quorum.log vote_001.quorum.txt  \
             vote_001_results.dot vote_001_results.png                    \
             leader2005_results.txt leader2005_tally.txt                  \
             leader2005_vote.png leader2005_vote_detailed.png             \
             Log-debian-dpl-debate.txt  Log-debian-dpl-replies.txt        \
             Log-debian-dpl-discuss.txt Log-debian-dpl-moderator.txt

desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
