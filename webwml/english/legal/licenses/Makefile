# This Makefile should need no changes from webwml/english/legal/licenses/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=legal/licenses
SUBS=

GETTEXTFILES += templates.mo

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/legal.wml \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/%.data $(GETTEXTDEP)
	$(WML) $(<F)

index.$(LANGUAGE).html: index.wml $(wildcard dls-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/dls-*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
	$(WML) $(<F)

bydate.$(LANGUAGE).html: bydate.wml $(wildcard dls-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/dls-*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml \
  $(TEMPLDIR)/legal_tags.wml $(GETTEXTDEP)
	$(WML) $(<F)

byname.$(LANGUAGE).html: byname.wml $(wildcard dls-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/dls-*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/legal_lists.wml $(GETTEXTDEP)
	$(WML) $(<F)

byclass.$(LANGUAGE).html: byclass.wml $(wildcard dls-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/dls-*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/legal_lists.wml $(GETTEXTDEP)
	$(WML) $(<F)
