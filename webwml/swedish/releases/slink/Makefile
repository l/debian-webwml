# This Makefile should need no changes from webwml/english/2.0/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=releases/slink
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

index.$(LANGUAGE).html: index.wml  \
		$(TEMPLDIR)/install_manual.wml \
		$(ENGLISHSRCDIR)/releases/slink/formats_and_architectures.wmh
	$(WML) index.wml