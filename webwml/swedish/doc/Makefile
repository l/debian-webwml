# This Makefile should need no changes from webwml/english/doc/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=doc
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.templ    
include $(WMLBASE)/Make.dep.generic

admin-manuals.$(LANGUAGE).html: admin-manuals.wml $(TEMPLDIR)/ddp.wml
cvs.$(LANGUAGE).html: cvs.wml $(TEMPLDIR)/ddp.wml
ddp.$(LANGUAGE).html: ddp.wml $(TEMPLDIR)/ddp.wml
devel-manuals.$(LANGUAGE).html: devel-manuals.wml $(TEMPLDIR)/ddp.wml
doc-manuals.$(LANGUAGE).html: doc-manuals.wml $(TEMPLDIR)/ddp.wml
docpolicy.$(LANGUAGE).html: docpolicy.wml $(TEMPLDIR)/ddp.wml
general-manuals.$(LANGUAGE).html: general-manuals.wml $(TEMPLDIR)/ddp.wml
packages.$(LANGUAGE).html: packages.wml $(TEMPLDIR)/ddp.wml
todo.$(LANGUAGE).html: todo.wml $(TEMPLDIR)/ddp.wml
topics.$(LANGUAGE).html: topics.wml $(TEMPLDIR)/ddp.wml
user-manuals.$(LANGUAGE).html: user-manuals.wml $(TEMPLDIR)/ddp.wml
