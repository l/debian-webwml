# This Makefile should need no changes from webwml/english/devel/wnpp/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/wnpp
SUBS=

NOGENERICDEP = true
include $(WMLBASE)/Make.lang

DATADIR = $(ENGLISHSRCDIR)/$(CUR_DIR)

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
  $(WMLBASE)/../.wmlrc $(WMLBASE)/.wmlrc $(DATADIR)/wnpp.data \
  $(GETTEXTDEP)
	$(WML) $(<F)

ifeq "$(LANGUAGE)" "en"
$(DATADIR)/wnpp.data:
	$(WML) $(DATADIR)/wnpp.pl
endif

.PHONY: $(DATADIR)/wnpp.data
.DELETE_ON_ERROR: $(DATADIR)/wnpp.data
