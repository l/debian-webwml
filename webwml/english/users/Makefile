# This Makefile should need no changes from webwml/english/users/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

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
