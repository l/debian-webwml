# This Makefile should need no changes from webwml/english/News/2000/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE = ../..
CUR_DIR = News/2000
SUBS =

include $(WMLBASE)/Make.lang


%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml
	$(WML) $(<F)
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml $(wildcard 2000*.wml) \
  $(wildcard $(ENGLISHDIR)/News/2000/2000*.wml)

# Specific to Chinese
%.zh-cn.html %.zh-hk.html %.zh-tw.html: %.wml $(TEMPLDIR)/news.wml \
		$(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
		$(TOCN) $(TOHK) $(TOTW) $(ZHTEMPLATE) $(HTMLDEP) \
		$(COMMONPICS_ZH)
	$(WML) $(<F)
#	# *.imgdot-1x1-transp.gif are evil!  Get rid of them!
#	# Must set nullglob or else the following fails - foka, June 2000
	@shopt -s nullglob; \
	for i in *.imgdot-1x1-transp.gif; do \
	    rm -f $$i; \
	    j=`basename $$i .imgdot-1x1-transp.gif` ; \
	    for k in $$j.$(LANGUAGE)-??.html.tmp; do \
		perl -pi -e "s|$$j\\.(?=imgdot-1x1-transp\\.gif)|$(WMLBASE)/Pics/|g" $$k; \
	    done; \
	done
	@echo -n " * Converting: [zh_CN.GB2312], "
	@$(B5TOGB) < $*.zh-cn.html.tmp > $*.zh-cn.html
	@rm -f $*.zh-cn.html.tmp
	@$(TOCN) $*.zh-cn.html
	@echo -n "[zh_HK.Big5], "
	@cp -f $*.zh-tw.html.tmp $*.zh-hk.html
	@$(TOHK) $*.zh-hk.html
	@echo "[zh_TW.Big5]."
	@mv -f $*.zh-tw.html.tmp $*.zh-tw.html
	@$(TOTW) $*.zh-tw.html

index.zh-cn.html index.zh-hk.html index.zh-tw.html: index.wml \
  $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/recent_list.wml $(wildcard 2000*.wml) \
  $(wildcard $(ENGLISHDIR)/News/2000/2000*.wml)
