# This Makefile should need no changes from webwml/english/international/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=international
SUBS=Chinese Swedish Croatian spanish l10n German Polish

include $(WMLBASE)/Make.lang


index.zh-cn.html index.zh-hk.html index.-tw.html: ../../english/international/index.data

install::
	test -L $(HTMLDIR)/zh || ln -sf Chinese $(HTMLDIR)/zh
