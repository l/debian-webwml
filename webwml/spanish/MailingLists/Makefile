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
ifeq "$(LANGUAGE)" "en"
	rm -f lists.cfg
endif
install:: $(HTMLDIR)/subscribe.$(LANGUAGE).html $(HTMLDIR)/unsubscribe.$(LANGUAGE).html

mklist := $(ENGLISHDIR)/$(CUR_DIR)/mklist
lists.cfg := $(ENGLISHDIR)/$(CUR_DIR)/lists.cfg
descfiles := $(shell find $(ENGLISHDIR)/$(CUR_DIR)/desc -type f \
                      ! -path '*/CVS/*' ! -name introduction \
                      ! -name subscription ! -name advertising ! -name README)
ifneq "$(wildcard desc)" ""
descfiles := $(shell find desc -type f ! -path '*/CVS/*' ! -name introduction \
                      ! -name subscription ! -name advertising ! -name README)
endif

subscribe.wml: $(mklist) $(lists.cfg) $(descfiles) $(mklist).tags
	$(mklist) -f $(lists.cfg) -s

unsubscribe.wml: $(mklist) $(lists.cfg) $(descfiles) $(mklist).tags
	$(mklist) -f $(lists.cfg) -u

ifeq "$(LANGUAGE)" "en"
mailing-lists.txt: $(mklist) $(lists.cfg) $(descfiles)
	$(mklist) -f $(lists.cfg) -t
$(lists.cfg):
	wget -O lists.cfg http://murphy.debian.org/lists.cfg
else
mailing-lists.$(LANGUAGE).txt: $(mklist) $(lists.cfg) $(descfiles)
	$(mklist) -f $(lists.cfg) -t && mv mailing-lists.txt mailing-lists.$(LANGUAGE).txt
endif
