# This Makefile should need no changes from webwml/english/vote/2001/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2004
SUBS=platforms
VOTE=$(basename $(wildcard vote_*.wml))

include $(WMLBASE)/Make.lang


$(foreach i, $(VOTE), $(i).$(LANGUAGE).html): %.$(LANGUAGE).html: %.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/../[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/../[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
  $(TEMPLDIR)/votebar.wml

ifeq "$(LANGUAGE)" "en"

textfiles := vote_001.quorum.err vote_001.quorum.log vote_001.quorum.txt \
             vote_001_results.dot  vote_001_results.png                  \
             vote_002.quorum.err vote_002.quorum.log vote_002.quorum.txt \
             vote_003.quorum.err vote_003.quorum.log vote_003.quorum.txt \
             vote_004.quorum.err vote_004.quorum.log vote_004.quorum.txt \
             vote_004_results.dot         vote_004_results.png           \
             gr_sarge_results.txt         gr_sarge_tally.txt             \
             gr_sarge_vote.png            gr_sarge_vote_detailed.png     \
             gr_sarge_voters.txt                                         \
             gr_non_free_results.txt      gr_non_free_tally.txt          \
             gr_non_free_vote.png         gr_non_free_vote_detailed.png  \
             gr_non_free_voters.txt                                      \
             gr_editorial_results.txt     gr_editorial_tally.txt         \
             gr_editorial_vote.png        gr_editorial_vote_detailed.png \
             gr_editorial_voters.txt                                     \
             leader2004_results.txt       leader2004_tally.txt           \
             leader2004_vote.png          leader2004_vote_detailed.png   \
             leader2004_voters.txt        social_contract_reform.3       
desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
