# This Makefile should need no changes from webwml/english/distrib/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=distrib
SUBS=

include $(WMLBASE)/Make.lang

books.$(LANGUAGE).html: books.wml $(ENGLISHSRCDIR)/distrib/books.def \
  $(TEMPLDIR)/countries.wml
ftplist.$(LANGUAGE).html: ftplist.wml $(ENGLISHSRCDIR)/distrib/ftplist.data \
  $(TEMPLDIR)/countries.wml
packages.$(LANGUAGE).html: packages.wml $(ENGLISHSRCDIR)/releases/info
pre-installed.$(LANGUAGE).html: pre-installed.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHSRCDIR)/distrib/pre-installed.data $(ENGLISHSRCDIR)/distrib/vendors.CD.def
vendors.$(LANGUAGE).html: vendors.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHSRCDIR)/distrib/vendors.CD $(ENGLISHSRCDIR)/distrib/vendors.CD.def
