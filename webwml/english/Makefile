# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=.
CUR_DIR=
SUBS=Bugs MailingLists News Pics banners chinese consultants devel distrib \
doc events intro international logos mirror misc partners ports releases \
searchtmpl security vote y2k

include $(WMLBASE)/Make.lang


ifneq "$(LANGUAGE)" "en"
sitemap.$(LANGUAGE).html: $(ENGLISHDIR)/sitemap.wml
ifneq "$(LANGUAGE)" "zh"
	$(shell echo $(WML) | sed s/index/sitemap/) \
          $(shell echo $(ENGLISHDIR) | sed s,./,,)/sitemap.wml \
            $(shell egrep '^-D (CUR_|CHAR)' .wmlrc)
else
	$(shell echo $(WML) | sed s/:.zh/:sitemap.zh/g) \
          $(shell echo $(ENGLISHDIR) | sed s,./,,)/sitemap.wml \
            $(shell egrep '^-D (CUR_|CHAR)' .wmlrc)
	@echo -n " * Converting: [zh_CN.GB2312], "
	@$(B5TOGB) < sitemap.zh-cn.html.tmp > sitemap.zh-cn.html
	@rm -f sitemap.zh-cn.html.tmp
	@$(TOCN) sitemap.zh-cn.html
	@echo -n "[zh_HK.Big5], "
	@mv -f sitemap.zh-hk.html.tmp sitemap.zh-hk.html
	@$(TOHK) sitemap.zh-hk.html
	@echo "[zh_TW.Big5]."
	@mv -f sitemap.zh-tw.html.tmp sitemap.zh-tw.html
	@$(TOTW) sitemap.zh-tw.html
endif
endif

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/mainpage.wml \
		$(wildcard News/$(CUR_YEAR)/[0-9]*.wml) $(wildcard $(ENGLISHSRCDIR)/News/$(CUR_YEAR)/[0-9]*.wml) \
		$(wildcard security/$(CUR_YEAR)/dsa-[0-9]*.wml) $(wildcard $(ENGLISHSRCDIR)/security/$(CUR_YEAR)/dsa-[0-9]*.wml) \
		$(TEMPLDIR)/ctime.wml $(TEMPLDIR)/recent_list.wml $(TEMPLDIR)/languages.wml \
		$(ENGLISHSRCDIR)/releases/info sitemap.$(LANGUAGE).html
	$(WML) index.wml

install::
	test -L $(HTMLDIR)/intl || ln -sf international $(HTMLDIR)/intl
ifneq "$(LANGUAGE)" "en"
	-install -m 664 -p sitemap.$(LANGUAGE)*.html $(HTMLDIR)
endif
