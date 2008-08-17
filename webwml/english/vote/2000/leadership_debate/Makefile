# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=vote/2000/leadership_debate
SUBS=

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/../../[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml

ifeq "$(LANGUAGE)" "en"
$(HTMLDIR)/informal.txt $(HTMLDIR)/transcript.txt: $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

install:: $(HTMLDIR)/informal.txt $(HTMLDIR)/transcript.txt
endif
