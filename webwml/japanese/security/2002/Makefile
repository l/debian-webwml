# This Makefile should need no changes from webwml/english/security/2002/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=security/2002
SUBS=

include $(WMLBASE)/Make.lang


%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/security.wml \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/%.data
	$(WML) $(<F)

index.$(LANGUAGE).html: index.wml $(wildcard dsa-[0-9]*.wml) \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/dsa-[0-9]*.data \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml
	$(WML) $(<F)
