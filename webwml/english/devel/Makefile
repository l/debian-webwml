# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

BASE=..
CUR_DIR=devel

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
# Do Not modify the following line
ENGLISHSRCDIR=$(BASE)/../english

include $(BASE)/Make.lang

all: $(HTMLFILES) $(JPGDEST)

include $(BASE)/Make.dep.templ    
include $(BASE)/Make.dep.generic

# Do Not modify the following line
$(HTMLDIR)/people.html.$(LANGUAGE): people.wml $(TEMPLDIR)/template.wml $(ENGLISHSRCDIR)/devel/people.names

people: people.wml
	$(WML) people.wml
