# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=vote/2000
SUBS=leadership_debate
VOTE=$(basename $(wildcard vote_*.wml))

include $(WMLBASE)/Make.lang


%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/template.wml
	$(WML) $(<F)
$(foreach i, $(VOTE), $(i).$(LANGUAGE).html): %.$(LANGUAGE).html: %.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/../[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/../[0-9]*/vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
  $(TEMPLDIR)/votebar.wml

ifeq "$(LANGUAGE)" "en"
textfiles := vote_0007_results.png vote_0007_results.dot
desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
