# This Makefile should need no changes from webwml/english/MailingLists/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=MailingLists
SUBS=

include $(WMLBASE)/Make.lang

all:: subscribe.$(LANGUAGE).html unsubscribe.$(LANGUAGE).html
clean::
	rm -f subscribe.wml unsubscribe.wml
install:: $(HTMLDIR)/subscribe.$(LANGUAGE).html $(HTMLDIR)/unsubscribe.$(LANGUAGE).html

mklist := $(ENGLISHDIR)/$(CUR_DIR)/mklist
lists.cfg := $(ENGLISHDIR)/$(CUR_DIR)/lists.cfg

subscribe.wml: $(mklist) $(lists.cfg)
	$(mklist) -f $(lists.cfg) -s

unsubscribe.wml: $(mklist) $(lists.cfg)
	$(mklist) -f $(lists.cfg) -u

ifeq "$(LANGUAGE)" "en"
mailing-lists.txt: $(mklist) $(lists.cfg)
	$(mklist) -f $(lists.cfg) -t
else
mailing-lists.$(LANGUAGE).txt: $(mklist) $(lists.cfg)
	$(mklist) -f $(lists.cfg) -t && mv mailing-lists.txt mailing-lists.$(LANGUAGE).txt
endif
