# This Makefile should need no changes from the one you copied
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../../..
CUR_DIR=vote/2000/leadership_debate
SUBS=

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/votebar.wml

ifeq "$(LANGUAGE)" "en"
$(HTMLDIR)/informal.txt $(HTMLDIR)/transcript.txt: $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

install:: $(HTMLDIR)/informal.txt $(HTMLDIR)/transcript.txt
endif
