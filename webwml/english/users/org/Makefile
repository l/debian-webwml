# This Makefile should need no changes from webwml/english/users/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=users/org
SUBS=

include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml\
	$(TEMPLDIR)/users.wml
	$(WML) $(<F)
