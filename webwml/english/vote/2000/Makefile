# This Makefile should need no changes from webwml/english/vote/2000/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2000
SUBS=leadership_debate

include $(WMLBASE)/Make.lang


%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/template.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

ifeq "$(LANGUAGE)" "en"
textfiles := vote_0007_results.png vote_0007_results.dot
desttextfiles := $(patsubst %,$(HTMLDIR)/%,$(textfiles))

install:: $(desttextfiles)

$(desttextfiles): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(desttextfiles)
endif
