# This Makefile should need no changes from webwml/english/vote/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=vote
SUBS=1999 2000 2001 2002

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*/vote_*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml

howto_follow.$(LANGUAGE).html: howto_follow.wml \
  $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml
howto_proposal.$(LANGUAGE).html: howto_proposal.wml \
  $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml
howto_result.$(LANGUAGE).html: howto_result.wml \
  $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml
howto_vote.$(LANGUAGE).html: howto_vote.wml \
  $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml

ifeq "$(LANGUAGE)" "en"
install::
	cp -a proposal.template $(HTMLDIR)
endif
