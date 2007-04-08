# This Makefile should need no changes from webwml/english/vote/2001/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2007
SUBS=platforms
VOTE=$(basename $(wildcard vote_*.wml))

include $(WMLBASE)/Make.lang


$(foreach i, $(VOTE), $(i).$(LANGUAGE).html): %.$(LANGUAGE).html: %.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/../[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(wildcard suppl_*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/../[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
  $(TEMPLDIR)/votebar.wml

ifeq "$(LANGUAGE)" "en"

textfiles := vote_001_quorum.err  vote_001_quorum.log  vote_001_quorum.txt   \
             vote_001_quorum.src  vote_001_results.src vote_001_majority.src \
             vote_001_index.src   vote_001_tally.txt   vote_001_voters.txt   \
             vote_001_vote.png    vote_001_results.png vote_001_results.dot  \
             vote_001_results.txt vote_001_results.png vote_001_vote_detailed.png \
             vote_002_quorum.err  vote_002_quorum.log  vote_002_quorum.txt   \
             vote_002_quorum.src  vote_002_results.src vote_002_majority.src \
             vote_002_index.src   vote_002_tally.txt   vote_002_voters.txt   \
             vote_002_vote.png    vote_002_results.png vote_002_results.dot  \
             vote_002_results.txt vote_002_vote_detailed.png



desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)


cleandest::
	rm -f $(desttextfiles)
endif

check:
	for i in $(wildcard *.$(LANGUAGE).html); do                         \
         echo $$i;                                                          \
         onsgmls -e -g -s -u /usr/share/sgml/declaration/html.decl $$i;     \
         echo $$i done;                                                     \
        done
