# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=devel
SUBS=website

include $(WMLBASE)/Make.lang

# Do Not modify the following line
people.$(LANGUAGE).html: people.wml $(TEMPLDIR)/template.wml \
	$(ENGLISHSRCDIR)/devel/people.names
index.$(LANGUAGE).html: index.wml \
	$(ENGLISHSRCDIR)/devel/index.include $(TEMPLDIR)/template.wml

# Special for Chinese
people.zh-cn.html people-zh-hk.html people.zh-tw.html: people.wml \
	$(TEMPLDIR)/template.wml $(ENGLISHSRCDIR)/devel/people.names
index.zh-cn.html index.zh-hk.html index.zh-tw.html: index.wml \
	$(ENGLISHSRCDIR)/devel/index.include $(TEMPLDIR)/template.wml
