# This Makefile should need no changes from webwml/english/security/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=security
SUBS=undated $(wildcard [12][0-9][0-9][0-9])

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

ifndef SUBLANG
DSARDF := dsa.$(LANGUAGE).rdf
DESTDSARDF := $(HTMLDIR)/$(DSARDF)
else
DSARDF := $(sort $(foreach i,$(SUBLANG),$(patsubst %.wml,%.$(LANGUAGE)-$(i).rdf,dsa.rdf)))
DESTDSARDF := $(patsubst %.rdf,$(HTMLDIR)/%.rdf,$(DSARDF))
endif

$(DSARDF): $(ENGLISHDIR)/security/dsa.rdf.in \
  $(wildcard $(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.wml) \
  $(wildcard $(ENGLISHDIR)/security/$(CUR_YEAR)/dsa-*.data) \
  $(TEMPLDIR)/recent_list.wml
ifeq "$(LANGUAGE)" "zh"
	$(subst :.zh,:dsa.zh,$(WML)) \
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

all:: $(DSARDF)

install:: $(DESTDSARDF)

$(DESTDSARDF): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)
ifeq "$(LANGUAGE)" "en"
	ln -sf dsa.en.rdf $(HTMLDIR)/dsa.rdf
endif

ifeq "$(LANGUAGE)" "en"
install:: $(HTMLDIR)/keys.txt

$(HTMLDIR)/keys.txt: $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)
endif
