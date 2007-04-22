# This Makefile should need no changes from webwml/english/volatile/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=volatile

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml

team.$(LANGUAGE).html: team.wml $(TEMPLDIR)/template.wml ../devel/debian-volatile/team.wml

volatile-mirrors.$(LANGUAGE).html: volatile-mirrors.wml $(TEMPLDIR)/template.wml volatile-mirrors.inc

volatile-mirrors.inc: 
	wget -q -O Mirrors.masterlist http://volatile.debian.org/debian-volatile/project/Mirrors.masterlist
	if [ `grep -i volatile-http Mirrors.masterlist|wc -l` -ne 0 ]; then perl -- $(ENGLISHDIR)/$(CUR_DIR)/volatile_mirror_list.pl >volatile-mirrors.inc; fi

submit.$(LANGUAGE).html: submit.wml $(TEMPLDIR)/countries_all.wml

.PHONY: volatile-mirrors.inc
