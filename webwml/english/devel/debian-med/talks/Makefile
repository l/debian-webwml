# This Makefile should need no changes from
# webwml/english/devel/debian-med/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=devel/debian-med/talks
SUBS=200210_lux_med 200210_lux_internal

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/200210_lux_med/*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/$(CUR_DIR)/200210_lux_internal/*.wml)
