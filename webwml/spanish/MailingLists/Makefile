# This Makefile should need no changes from webwml/english/MailingLists/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=MailingLists
SUBS=

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"
subscribe.wml: mklist lists.cfg
	./mklist -s

unsubscribe.wml: mklist lists.cfg
	./mklist -u
endif
