# This Makefile should need no changes from webwml/english/searchtmpl/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=searchtmpl
SUBS=

GETTEXTFILES = search.mo

include $(WMLBASE)/Make.lang

search.$(LANGUAGE).html: search.wml $(ENGLISHSRCDIR)/searchtmpl/search.data \
  $(ENGLISHSRCDIR)/searchtmpl/search.def $(TEMPLDIR)/common_translation.wml \
  $(TEMPLDIR)/basic.wml $(TEMPLDIR)/languages.wml $(TEMPLDIR)/footer.wml \
  $(GETTEXTDEP)
	$(WML) $<
# XXX this likely doesn't work at all for SUBLANG-enabled languages!
	c=`grep CHARSET ../.wmlrc | cut -d= -f2`; \
          iconv -f $$c -t UTF-8 $@; \
          perl -pi -e 's,^(\s*<meta http-equiv="Content-Type" content="text/html; charset=)\S+(">)$$,$$1UTF-8$$2,' $@
