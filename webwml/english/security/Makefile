# This Makefile should need no changes from webwml/english/security/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=security
SUBS=undated $(wildcard [12][0-9][0-9][0-9])

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

# additional files, English-only (for now at least)
ifeq "$(LANGUAGE)" "en"

dsa.rdf: dsa.rdf.in $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(TEMPLDIR)/recent_list.wml
	wml $(WMLOPTIONS) -o dsa.rdf dsa.rdf.in

install:: $(HTMLDIR)/keys.txt $(HTMLDIR)/dsa.rdf

$(HTMLDIR)/keys.txt $(HTMLDIR)/dsa.rdf: $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)
endif
