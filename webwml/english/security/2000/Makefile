# This Makefile should need no changes from webwml/english/security/2000/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=security/2000
SUBS=

include $(WMLBASE)/Make.lang


%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/security.wml \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/%.data $(GETTEXTDEP)
	$(WML) $(<F)

index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/[0-9]*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
	$(WML) $(<F)
