# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=users
SUBS=edu com org gov

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml\
	$(wildcard edu/*.wml) $(wildcard $(ENGLISHSRCDIR)/users/edu/*.wml) \
	$(wildcard com/*.wml) $(wildcard $(ENGLISHSRCDIR)/users/com/*.wml) \
	$(wildcard org/*.wml) $(wildcard $(ENGLISHSRCDIR)/users/org/*.wml) \
	$(wildcard gov/*.wml) $(wildcard $(ENGLISHSRCDIR)/users/gov/*.wml) \
	$(TEMPLDIR)/template.wml  $(TEMPLDIR)/users_list.wml \
	$(TEMPLDIR)/languages.wml $(TEMPLDIR)/users.wml $(GETTEXTDEP)
	$(WML) $(<F)
