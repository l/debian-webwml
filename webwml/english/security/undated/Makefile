# This Makefile should need no changes from webwml/english/security/1998/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

BASE=../..
CUR_DIR=security/undated

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
# Do Not modify the following line
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

all: $(HTMLFILES)

#include $(BASE)/Make.templ.inc

# Do Not modify the following lines
$(HTMLDIR)/index.html.$(LANGUAGE): index.wml $(wildcard undated*.wml) $(TEMPLDIR)/basic.wml $(TEMPLDIR)/recent_list.wml

$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/footer.wml $(TEMPLDIR)/languages.wml $(TEMPLDIR)/security.wml $(TEMPLDIR)/fixes_link.wml
	$(WML) $(<F)
