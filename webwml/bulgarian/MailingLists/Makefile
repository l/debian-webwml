# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=MailingLists
SUBS=

GETTEXTFILES += others.mo

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "zh"
all:: $(foreach sl,$(SUBLANG),subscribe.$(LANGUAGE)-$(sl).html unsubscribe.$(LANGUAGE)-$(sl).html )
install:: $(foreach sl,$(SUBLANG),$(HTMLDIR)/subscribe.$(LANGUAGE)-$(sl).html $(HTMLDIR)/unsubscribe.$(LANGUAGE)-$(sl).html )
else
all:: subscribe.$(LANGUAGE).html unsubscribe.$(LANGUAGE).html
install:: $(HTMLDIR)/subscribe.$(LANGUAGE).html $(HTMLDIR)/unsubscribe.$(LANGUAGE).html
endif

clean::
	rm -f subscribe.wml unsubscribe.wml 
ifeq "$(LANGUAGE)" "en"
	rm -f lists.cfg
endif

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
	wget -O lists.cfg http://lists.debian.org/lists.cfg
else
mailing-lists.$(LANGUAGE).txt: $(mklist) $(lists.cfg) $(descfiles)
	$(mklist) -f $(lists.cfg) -t && mv mailing-lists.txt mailing-lists.$(LANGUAGE).txt
endif
