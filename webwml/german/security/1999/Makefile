# This Makefile should need no changes from webwml/english/security/1999/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=security/1999
SUBS=

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/[0-9]*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml
	$(WML) $(<F)

%.$(LANGUAGE).html: %.wml $(ENGLISHSRCDIR)/$(CUR_DIR)/%.data \
  $(TEMPLDIR)/security.wml
	$(WML) $(<F)
