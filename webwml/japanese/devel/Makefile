# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=devel
SUBS=website debian-jr join wnpp

include $(WMLBASE)/Make.lang

people.$(LANGUAGE).html: people.wml $(TEMPLDIR)/template.wml \
 $(ENGLISHSRCDIR)/devel/people.names
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/develbar.wml

# the WNPP files have to be forced to rebuild, because they're dynamic data
work_needing.$(LANGUAGE).html prospective.$(LANGUAGE).html: FORCE
rfa_bypackage.$(LANGUAGE).html rfa_bymaint.$(LANGUAGE).html: FORCE
orphaned.$(LANGUAGE).html withdrawn.$(LANGUAGE).html: FORCE
being_adopted.$(LANGUAGE).html: FORCE
requested.$(LANGUAGE).html being_packaged.$(LANGUAGE).html: FORCE

FORCE:
