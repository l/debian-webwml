# This Makefile should need no changes from webwml/english/security/1997/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=security/1997
SUBS=

include $(WMLBASE)/Make.lang


# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(wildcard 1997*.wml) $(TEMPLDIR)/basic.wml $(TEMPLDIR)/recent_list.wml
	$(WML) index.wml

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/footer.wml $(TEMPLDIR)/languages.wml $(TEMPLDIR)/security.wml $(TEMPLDIR)/fixes_link.wml
	$(WML) $(<F)
