# This Makefile should need no changes from
# the file webwml/english/devel/debian-volatile/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/debian-volatile

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml

volatile-mirrors.$(LANGUAGE).html: volatile-mirrors.wml $(TEMPLDIR)/template.wml volatile-mirrors.inc

volatile-mirrors.inc: 
	wget http://volatile.debian.net/debian-volatile/project/Mirrors.masterlist
	perl -f volatile_mirror_list.pl >volatile-mirrors.inc

team.$(LANGUAGE).html: team.wml $(TEMPLDIR)/template.wml

