# This Makefile should need no changes from webwml/english/searchtmpl/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=searchtmpl
SUBS=

GETTEXTFILES = search.mo

include $(WMLBASE)/Make.lang

all:: search-convert

search.$(LANGUAGE).html: search.wml $(ENGLISHSRCDIR)/searchtmpl/search.data \
  $(ENGLISHSRCDIR)/searchtmpl/search.def $(TEMPLDIR)/common_translation.wml \
  $(TEMPLDIR)/basic.wml $(TEMPLDIR)/languages.wml $(TEMPLDIR)/footer.wml \
  $(GETTEXTDEP)

search-convert: search.$(LANGUAGE).html
	c=`grep '^<meta http-equiv="Content-Type" content="text/html; charset=.*">' $? | sed -e 's/^<meta http-equiv="Content-Type" content="text\/html; charset=\(.*\)">/\1/'`; \
          iconv -f $$c -t UTF-8 $? | sed -e 's/<meta http-equiv="Content-Type" content="text\/html; charset=.*">/<meta http-equiv="Content-Type" content="text\/html; charset=UTF-8">/' > $?.tmp && mv $?.tmp $?
