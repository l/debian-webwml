# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=security/2004
SUBS=

GETTEXTFILES += security.mo

NOGENERICDEP := true
include $(WMLBASE)/Make.lang


%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/security.wml \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/%.data $(GETTEXTDEP)
	$(WML) $(<F)

index.$(LANGUAGE).html: index.wml $(wildcard dsa-[0-9]*.wml) \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/dsa-[0-9]*.data \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
	$(WML) $(<F)

CAN-2004-0077.$(LANGUAGE).html: CAN-2004-0077.wml \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/CAN-2004-0077.data \
  $(GETTEXTDEP) $(TEMPLDIR)/template.wml
	$(WML) $(<F)

CAN-2004-0109.$(LANGUAGE).html: CAN-2004-0109.wml \
  $(ENGLISHSRCDIR)/$(CUR_DIR)/CAN-2004-0109.data \
  $(GETTEXTDEP) $(TEMPLDIR)/template.wml
	$(WML) $(<F)
