# This Makefile should need no changes from webwml/english/security/2000/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=../..
CUR_DIR=security/2000
SUBS=

include $(WMLBASE)/Make.lang


# Do Not modify the following lines
index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*.wml) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/footer.wml \
		$(TEMPLDIR)/languages.wml $(TEMPLDIR)/security.wml \
		$(TEMPLDIR)/fixes_link.wml $(ENGLISHSRCDIR)/security/2000/%.data
	$(WML) $(<F)
