# This Makefile should need no changes from webwml/english/security/1998/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=security/undated
SUBS=

include $(WMLBASE)/Make.lang


# Do Not modify the following lines
index.$(LANGUAGE).html: index.wml $(wildcard undated*.wml) $(TEMPLDIR)/basic.wml $(TEMPLDIR)/recent_list.wml
	$(WML) index.wml

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/footer.wml \
		$(TEMPLDIR)/languages.wml $(TEMPLDIR)/security.wml \
		$(TEMPLDIR)/fixes_link.wml $(ENGLISHSRCDIR)/security/undated/%.data
	$(WML) $(<F)
