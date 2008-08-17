# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=vote
SUBS=$(wildcard [12][0-9][0-9][0-9])

include $(WMLBASE)/Make.lang

GETTEXTFILES += vote.mo

index.$(LANGUAGE).html: index.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml $(GETTEXTDEP)

howto_follow.$(LANGUAGE).html: howto_follow.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml $(GETTEXTDEP)
howto_proposal.$(LANGUAGE).html: howto_proposal.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml $(GETTEXTDEP)
# howto_result.$(LANGUAGE).html: howto_result.wml \
#   $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml
# howto_vote.$(LANGUAGE).html: howto_vote.wml \
#   $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml

ifeq "$(LANGUAGE)" "en"
install::
	cp -a sample_vote.template $(HTMLDIR)
endif
