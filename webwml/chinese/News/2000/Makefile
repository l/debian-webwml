# This Makefile should need no changes from webwml/english/News/2000/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE = ../..
CUR_DIR = News/2000
SUBS =
HTMLDEP = $(TEMPLDIR)/news.wml

include $(WMLBASE)/Make.lang

# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(wildcard 2000*.wml) \
                        $(wildcard 2000*.title)\
                        $(TEMPLDIR)/recent_list.wml

# Specific to Chinese
index.zh-cn.html index.zh-tw.html: index.wml $(wildcard 2000*.wml) \
                        $(wildcard 2000*.title) \
                        $(TEMPLDIR)/recent_list.wml
