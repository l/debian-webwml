# This Makefile should need no changes from webwml/english/News/1997/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

BASE=../..
CUR_DIR=News/1997

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
# Do Not modify the following line
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

all: $(HTMLFILES) $(JPGDEST)

include $(BASE)/Make.dep.templ    

# Do Not modify the following line
$(HTMLDIR)/index.html.$(LANGUAGE): index.wml $(wildcard 1997*.wml) $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml
	$(WML) index.wml

$(HTMLDIR)/%.html.$(LANGUAGE): %.wml $(wildcard 1997*.wml) $(TEMPLDIR)/news.wml
	$(WML) $(<F)
