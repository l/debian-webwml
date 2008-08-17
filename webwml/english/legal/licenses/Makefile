# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=legal/licenses
SUBS=

GETTEXTFILES += legal.mo

NOGENERICDEP := true
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
