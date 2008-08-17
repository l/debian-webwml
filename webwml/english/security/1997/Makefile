# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=security/1997
SUBS=

NOGENERICDEP := true
include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/[0-9]*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml
	$(WML) $(<F)

%.$(LANGUAGE).html: %.wml $(ENGLISHSRCDIR)/$(CUR_DIR)/%.data \
  $(TEMPLDIR)/security.wml
	$(WML) $(<F)
