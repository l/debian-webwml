# This Makefile should need no changes from webwml/english/doc/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=doc
SUBS=

include $(WMLBASE)/Make.lang


%-manuals.$(LANGUAGE).html: %-manuals.wml $(TEMPLDIR)/ddp.wml $(ENGLISHSRCDIR)/doc/manuals.defs
	$(WML) $(<F)

cvs.$(LANGUAGE).html: cvs.wml $(TEMPLDIR)/ddp.wml $(ENGLISHSRCDIR)/doc/dirtree.jpg
ddp.$(LANGUAGE).html: ddp.wml $(TEMPLDIR)/ddp.wml
docpolicy.$(LANGUAGE).html: docpolicy.wml $(TEMPLDIR)/ddp.wml
todo.$(LANGUAGE).html: todo.wml $(TEMPLDIR)/ddp.wml
topics.$(LANGUAGE).html: topics.wml $(TEMPLDIR)/ddp.wml
