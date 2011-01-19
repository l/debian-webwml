# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=devel/debian-installer
SUBS=News

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html:: $(TEMPLDIR)/recent_list.wml \
	$(wildcard News/[12][0-9][0-9][0-9]/[0-9]*.wml) \
	$(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/News/[12][0-9][0-9][0-9]/[0-9]*.wml) \
	$(ENGLISHSRCDIR)/$(CUR_DIR)/images.data \
	$(TEMPLDIR)/release_info.wml

$(ENGLISHSRCDIR)/$(CUR_DIR)/images.data: $(TEMPLDIR)/installer.wml
	touch $@

# last line
