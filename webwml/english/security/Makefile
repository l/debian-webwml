# This Makefile should need no changes from webwml/english/security/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=security
SUBS=undated $(wildcard [12][0-9][0-9][0-9]) audit

GETTEXTFILES += security.mo

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(ENGLISHSRCDIR)/releases/info \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)

faq.$(LANGUAGE).html: faq.wml \
  $(ENGLISHSRCDIR)/security/faq.wml \
  $(ENGLISHSRCDIR)/security/faq.inc $(GETTEXTDEP)

$(ENGLISHSRCDIR)/security/ref-table.inc: $(ENGLISHSRCDIR)/security/make-ref-table.pl $(wildcard $(ENGLISHSRCDIR)/security/*/*.data) 
	perl $(ENGLISHSRCDIR)/security/make-ref-table.pl -p -a >$(ENGLISHSRCDIR)/security/ref-table.inc

crossreferences.$(LANGUAGE).html:: $(ENGLISHSRCDIR)/security/ref-table.inc \
	$(ENGLISHDIR)/template/debian/securityreferences.wml 


# only depend on it if it exists
translated_nonvulns-woody=$(shell [ -f nonvulns-woody.src ] && echo nonvulns-woody.src)
nonvulns-woody.$(LANGUAGE).html: nonvulns-woody.wml $(translated_nonvulns-woody)  \
	$(ENGLISHSRCDIR)/security/nonvulns-woody.src \
	$(TEMPLDIR)/securityreferences.wml 

translated_nonvulns-sarge=$(shell [ -f nonvulns-sarge.src ] && echo nonvulns-sarge.src)
nonvulns-sarge.$(LANGUAGE).html: nonvulns-sarge.wml $(translated_nonvulns-sarge)  \
	$(ENGLISHSRCDIR)/security/nonvulns-sarge.src \
	$(TEMPLDIR)/securityreferences.wml 

translated_nonvulns-etch=$(shell [ -f nonvulns-etch.src ] && echo nonvulns-etch.src)
nonvulns-etch.$(LANGUAGE).html: nonvulns-etch.wml $(translated_nonvulns-etch)  \
	$(ENGLISHSRCDIR)/security/nonvulns-etch.src \
	$(TEMPLDIR)/securityreferences.wml 

clean::
	rm -f $(DSARDF) $(DSALONGRDF)
ifeq "$(LANGUAGE)" "ja"
	rm -f $(DSARDF).tmp $(DSALONGRDF).tmp
endif
	rm -f ref-table.inc

ifndef SUBLANG
DSARDF     := dsa.$(LANGUAGE).rdf
DSALONGRDF := dsa-long.$(LANGUAGE).rdf
DSAALLRDF := dsa-all.$(LANGUAGE).rdf
DESTDSARDF     := $(HTMLDIR)/$(DSARDF)
DESTDSALONGRDF := $(HTMLDIR)/$(DSALONGRDF)
else
DSARDF     := $(sort $(foreach i,$(SUBLANG),$(subst dsa,dsa.$(LANGUAGE)-$(i),dsa.rdf)))
DSALONGRDF := $(sort $(foreach i,$(SUBLANG),$(subst dsa-long,dsa-long.$(LANGUAGE)-$(i),dsa-long.rdf)))
DSAALLRDF := $(sort $(foreach i,$(SUBLANG),$(subst dsa-all,dsa-all.$(LANGUAGE)-$(i),dsa-all.rdf)))
DESTDSARDF     := $(patsubst %.rdf,$(HTMLDIR)/%.rdf,$(DSARDF))
DESTDSALONGRDF := $(patsubst %.rdf,$(HTMLDIR)/%.rdf,$(DSALONGRDF))
endif

$(DSARDF): $(ENGLISHDIR)/security/dsa.rdf.in \
  $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "zh"
	$(shell echo $(WML) | perl -pe 's,:.zh-(..)\.html,:dsa.zh-$$1.rdf,g') \
          $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa.rdf.in
	@echo -n " * Converting: [zh_CN.GB2312], "
	@$(B5TOGB) < dsa.zh-cn.rdf.tmp > dsa.zh-cn.rdf
	@rm -f dsa.zh-cn.rdf.tmp
	@$(TOCN) dsa.zh-cn.rdf
	@echo -n "[zh_HK.Big5], "
	@mv -f dsa.zh-hk.rdf.tmp dsa.zh-hk.rdf
	@$(TOHK) dsa.zh-hk.rdf
	@echo "[zh_TW.Big5]."
	@mv -f dsa.zh-tw.rdf.tmp dsa.zh-tw.rdf
	@$(TOTW) dsa.zh-tw.rdf
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa.rdf.in
endif

$(DSALONGRDF): $(ENGLISHDIR)/security/dsa-long.rdf.in \
  $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "zh"
	$(shell echo $(WML) | perl -pe 's,:.zh-(..)\.html,:dsa-long.zh-$$1.rdf,g') \
          $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa-long.rdf.in
	@echo -n " * Converting: [zh_CN.GB2312], "
	@$(B5TOGB) < dsa-long.zh-cn.rdf.tmp > dsa-long.zh-cn.rdf
	@rm -f dsa-long.zh-cn.rdf.tmp
	@$(TOCN) dsa-long.zh-cn.rdf
	@echo -n "[zh_HK.Big5], "
	@mv -f dsa-long.zh-hk.rdf.tmp dsa-long.zh-hk.rdf
	@$(TOHK) dsa-long.zh-hk.rdf
	@echo "[zh_TW.Big5]."
	@mv -f dsa-long.zh-tw.rdf.tmp dsa-long.zh-tw.rdf
	@$(TOTW) dsa-long.zh-tw.rdf
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa-long.rdf.in
endif

$(DSAALLRDF): $(ENGLISHDIR)/security/dsa-all.rdf.in \
  $(wildcard ????/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/????/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/????/dsa-*.data) \
  $(TEMPLDIR)/recent_list.wml $(GETTEXTDEP)
ifeq "$(LANGUAGE)" "zh"
	$(shell echo $(WML) | perl -pe 's,:.zh-(..)\.html,:dsa-all.zh-$$1.rdf,g') \
          $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa-all.rdf.in
	@echo -n " * Converting: [zh_CN.GB2312], "
	@$(B5TOGB) < dsa-all.zh-cn.rdf.tmp > dsa-all.zh-cn.rdf
	@rm -f dsa-all.zh-cn.rdf.tmp
	@$(TOCN) dsa-all.zh-cn.rdf
	@echo -n "[zh_HK.Big5], "
	@mv -f dsa-all.zh-hk.rdf.tmp dsa-all.zh-hk.rdf
	@$(TOHK) dsa-all.zh-hk.rdf
	@echo "[zh_TW.Big5]."
	@mv -f dsa-all.zh-tw.rdf.tmp dsa-all.zh-tw.rdf
	@$(TOTW) dsa-all.zh-tw.rdf
else
	$(WML) $(shell egrep '^-D (CUR_|CHAR)' ../.wmlrc) \
            $(ENGLISHDIR)/security/dsa-all.rdf.in
endif


all:: $(DSARDF) $(DSALONGRDF)

install:: $(DESTDSARDF) $(DESTDSALONGRDF) 

$(DESTDSARDF): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)
ifeq "$(LANGUAGE)" "en"
	ln -sf dsa.en.rdf $(HTMLDIR)/dsa.rdf
endif
$(DESTDSALONGRDF): $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)
ifeq "$(LANGUAGE)" "en"
	ln -sf dsa-long.en.rdf $(HTMLDIR)/dsa-long.rdf
endif

ifeq "$(LANGUAGE)" "en"
install:: $(HTMLDIR)/keys.txt

$(HTMLDIR)/keys.txt: $(HTMLDIR)/%: %
	@test -d $(HTMLDIR) || mkdir -m g+w -p $(HTMLDIR)
	install -m 664 -p $< $(HTMLDIR)
endif
