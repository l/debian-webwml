# This Makefile should need no changes from webwml/english/News/1997/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=News/1997
SUBS=

include $(WMLBASE)/Make.lang


# Do Not modify the following line
index.$(LANGUAGE).html: index.wml $(wildcard 1997*.wml) \
                        $(wildcard 1997*.title) \
                        $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml
	$(WML) index.wml
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/news.wml
	$(WML) $(<F)

ifeq ($(LANGUAGE),en)
$(HTMLDIR)/common_library $(HTMLDIR)/linux_press_book.txt: $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

install:: $(HTMLDIR)/common_library $(HTMLDIR)/linux_press_book.txt
endif
