# This Makefile should need no changes from
# webwml/english/devel/debian-med/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/debian-med
SUBS=News talks

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/News/[0-9]*/*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/talks/*.wml)


#  $(wildcard ../../../german/devel/debian-med/News/[0-9]*/*.wml)

#packaged.$(LANGUAGE).html: packaged.wml \
#  $(ENGLISHSRCDIR)/devel/debian-med/packaged.tags \
#  $(wildcard $(ENGLISHSRCDIR)/devel/debian-med/packaged/*/*) \
#  $(wildcard $(ENGLISHSRCDIR)/devel/debian-med/packaged-non-free/*/*)
