# This Makefile should need no changes from webwml/english/2.0/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=distrib
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

vendors.$(LANGUAGE).html: vendors.wml ../../english/distrib/vendors.CD \
		../../english/distrib/vendors.CD.def $(TEMPLDIR)/template.wml $(TEMPLDIR)/countries.wml
pre-installed.$(LANGUAGE).html: ../../english/distrib/pre-installed.data
