# This Makefile should need no changes from webwml/english/vote/2000/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=vote/2000
SUBS=

include $(WMLBASE)/Make.lang


%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/footer.wml \
  $(TEMPLDIR)/languages.wml $(TEMPLDIR)/votebar.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(wildcard vote_*.wml) \
  $(TEMPLDIR)/basic.wml $(TEMPLDIR)/recent_list.wml
