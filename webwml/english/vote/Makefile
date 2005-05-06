# This Makefile should need no changes from webwml/english/vote/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=vote
SUBS=$(wildcard [12][0-9][0-9][0-9])

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: howto_follow.wml howto_proposal.wml \
  index.wml $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml

howto_follow.$(LANGUAGE).html: howto_follow.wml \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml
howto_proposal.$(LANGUAGE).html: howto_proposal.wml \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml
# howto_result.$(LANGUAGE).html: howto_result.wml \
#   $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml
# howto_vote.$(LANGUAGE).html: howto_vote.wml \
#   $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml

ifeq "$(LANGUAGE)" "en"
install::
	cp -a proposal.template $(HTMLDIR)
endif
