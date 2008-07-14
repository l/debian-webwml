# This Makefile should need no changes from
#    webwml/english/security/audit/2003/Makefile
#
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=security/audit/2003

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"
$(ENGLISHSRCDIR)/security/audit/data/2003.inc: $(ENGLISHSRCDIR)/security/audit/data/2003.data
	$(ENGLISHSRCDIR)/security/audit/make-advisories $(ENGLISHSRCDIR)/security/audit/data
endif

index.$(LANGUAGE).html: index.wml \
  $(ENGLISHSRCDIR)/security/audit/data/2003.inc \
  $(ENGLISHSRCDIR)/security/audit/data/2003.data
