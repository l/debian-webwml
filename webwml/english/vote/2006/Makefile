# This Makefile should need no changes from webwml/english/vote/2001/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2006
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

textfiles := vote_001.quorum.err vote_001.quorum.log vote_001.quorum.txt  \
             vote_002.quorum.err vote_002.quorum.log vote_002.quorum.txt

desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
