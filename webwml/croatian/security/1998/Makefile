# This Makefile should need no changes from webwml/english/security/1998/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=security/1998
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    

# Do Not modify the following lines
index.html.$(LANGUAGE): index.wml $(wildcard 1998*.wml) $(TEMPLDIR)/basic.wml $(TEMPLDIR)/recent_list.wml
	$(WML) index.wml

%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/footer.wml $(TEMPLDIR)/languages.wml $(TEMPLDIR)/security.wml $(TEMPLDIR)/fixes_link.wml
	$(WML) $(<F)
