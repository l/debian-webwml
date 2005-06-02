# This Makefile should need no changes from
# the file webwml/english/devel/debian-installer/Makefile
# because webwml/english/devel/debian-installer/Makefile is "upstream"
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/debian-installer
SUBS=News

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html:: $(TEMPLDIR)/recent_list.wml \
	$(wildcard News/[12][0-9][0-9][0-9]/[0-9]*.wml) \
	$(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/News/[12][0-9][0-9][0-9]/[0-9]*.wml) \
	$(ENGLISHSRCDIR)/$(CUR_DIR)/images.data

$(ENGLISHSRCDIR)/$(CUR_DIR)/images.data: $(TEMPLDIR)/installer.wml
	touch $@

# last line
