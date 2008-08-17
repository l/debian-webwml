# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=users
SUBS=edu com org gov

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml\
	$(wildcard edu/*.wml) \
	$(wildcard com/*.wml) \
	$(wildcard org/*.wml) \
	$(wildcard gov/*.wml) \
	$(TEMPLDIR)/template.wml  $(TEMPLDIR)/users_list.wml \
	$(TEMPLDIR)/languages.wml $(TEMPLDIR)/users.wml $(GETTEXTDEP)
	$(WML) $(<F)
