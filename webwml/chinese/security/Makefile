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

# install keys.txt
ifeq ($(LANGUAGE),en)
install:: $(HTMLDIR)/keys.txt

$(HTMLDIR)/keys.txt: keys.txt
	install keys.txt $(HTMLDIR)
endif
