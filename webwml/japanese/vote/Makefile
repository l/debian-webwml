# This Makefile should need no changes from webwml/english/vote/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=vote
SUBS=1999 2000 2001 2002

NOGENERICDEP := true
include $(WMLBASE)/Make.lang


%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/$(CUR_YEAR)/*.wml) \
  $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml
