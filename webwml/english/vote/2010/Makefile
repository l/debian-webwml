# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=vote/2010
SUBS=platforms
VOTE=$(basename $(wildcard vote_*.wml))

include $(WMLBASE)/Make.lang


$(foreach i, $(VOTE), $(i).$(LANGUAGE).html): %.$(LANGUAGE).html: %.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/../[0-9]*/vote_*.wml) \
  $(wildcard vote_*_quorum.txt) $(wildcard vote_*_quorum.src) \
  $(wildcard vote_*_majority.txt) $(wildcard vote_*_majority.src) \
  $(wildcard vote_*_results.src) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/../[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
  $(TEMPLDIR)/votebar.wml

$(foreach i, $(basename $(wildcard suppl_*_stats.wml)), $(i).$(LANGUAGE).html): \
%.$(LANGUAGE).html: %.wml $(wildcard vote_*_index.src)
	$(WML) $(<F)

ifeq "$(LANGUAGE)" "en"

textfiles :=  vote_001_quorum.err  vote_001_quorum.log  \
              vote_001_tally.txt   vote_001_voters.txt  \
              vote_001_results.dot vote_001_results.txt \
              vote_001_results.png vote_001_quorum.txt  \
              vote_001_vote.png                         \
              vote_001_vote_detailed.png                \
              vote_002_tally.txt   vote_002_voters.txt  \
              vote_002_vote.png    vote_002_results.png \
              vote_002_results.dot vote_002_results.txt \
              vote_002_vote_detailed.png                \
              vote_002_quorum.txt


             # vote_002_quorum.err  vote_002_quorum.log  \ #
             # vote_003_quorum.err  vote_003_quorum.log  \ #
             # vote_003_tally.txt   vote_003_voters.txt  \ #
             # vote_003_vote.png    vote_003_results.png \ #
             # vote_003_results.dot vote_003_results.txt \ #
             # vote_003_vote_detailed.png                \ #
             # vote_004_quorum.err  vote_004_quorum.log  \ #
             # vote_004_tally.txt   vote_004_voters.txt  \ #
             # vote_004_vote.png    vote_004_results.png \ #
             # vote_004_results.dot vote_004_results.txt \ #
             # vote_004_vote_detailed.png		   #
             ###############################################



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
