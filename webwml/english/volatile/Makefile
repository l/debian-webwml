# This Makefile should need no changes from webwml/english/volatile/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=volatile

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml

team.$(LANGUAGE).html: team.wml $(TEMPLDIR)/template.wml ../devel/debian-volatile/team.wml

volatile-mirrors.$(LANGUAGE).html: volatile-mirrors.wml $(TEMPLDIR)/template.wml volatile-mirrors.inc

volatile-mirrors.inc: $(ENGLISHSRCDIR)/mirror/Mirrors.masterlist $(ENGLISHSRCDIR)/mirror/mirror_list.pl
#	wget -q -O Mirrors.masterlist http://volatile.debian.org/debian-volatile/project/Mirrors.masterlist
	$(ENGLISHSRCDIR)/mirror/mirror_list.pl -t volatile-html > volatile-mirrors.inc

ifeq "$(LANGUAGE)" "en"

mirrorstuff := etch-volatile.asc id_mirrorpush.pub mirror-volatile.sh ziyi-sarge.asc

destmirrorstuff := $(patsubst %,$(HTMLDIR)/%,$(mirrorstuff))

install:: $(destmirrorstuff)

$(destmirrorstuff): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(destmirrorstuff)
endif
