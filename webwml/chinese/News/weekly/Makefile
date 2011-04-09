include $(subst webwml/chinese,webwml/english,$(CURDIR))/Makefile

# Ugly hack to handle the "cd" just before wml...
FORMAT_ZH := $(CURDIR)/$(FORMAT_ZH)

%.zh-cn.html %.zh-hk.html %.zh-tw.html : %.wml \
			   $(TEMPLDIR)/weeklynews/footer.wml \
			   $(TEMPLDIR)/weeklynews/header.wml $(GETTEXTDEP) \
			   $(COMMON_SCRIPTS)
	@cd $(@D) && $(WML) $(notdir $(<))
	@$(GENERATE_ZH_VARIANTS) $* html

$(HTMLDIR)/%.zh-cn.html: %.zh-cn.html
	@test -d $(@D) || mkdir -m g+w -p $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)
$(HTMLDIR)/%.zh-hk.html: %.zh-hk.html
	@test -d $(@D) || mkdir -m g+w -p $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)
$(HTMLDIR)/%.zh-tw.html: %.zh-tw.html
	@test -d $(@D) || mkdir -m g+w -p $(@D)
	@echo copying $(@F) to $(@D)
	-@install -m 664 -p $(<) $(@D)

clean::
	-find . -type f -name \*.$(LANGUAGE)-??.html | xargs rm -f

index.zh-cn.html index.zh-hk.html index.zh-tw.html: index.wml \
      $(wildcard $(CUR_YEAR)/*/index.wml) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(CUR_YEAR)/*/index.wml) \
      $(ENGLISHSRCDIR)/$(CUR_DIR)/CURRENT-ISSUE-IS \
      $(TEMPLDIR)/weeklynews/header.wml \
      $(TEMPLDIR)/weeklynews/index.wml \
      $(TEMPLDIR)/weeklynews/footer.wml $(GETTEXTDEP)

[0-9]*/index.zh-cn.html [0-9]*/index.zh-hk.html [0-9]*/index.zh-tw.html: \
	$(shell find $* -name index.wml) \
	$(wildcard 1999/*/index.wml) \
	$(wildcard $(ENGLISHSRCDIR)/News/weekly/$*/*/index.wml) \
	$(TEMPLDIR)/weeklynews/header.wml \
	$(TEMPLDIR)/weeklynews/index.wml \
	$(TEMPLDIR)/weeklynews/footer.wml $(GETTEXTDEP)
