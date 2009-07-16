# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=volatile

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml

team.$(LANGUAGE).html: team.wml $(TEMPLDIR)/template.wml ../devel/debian-volatile/team.wml

volatile-mirrors.$(LANGUAGE).html: volatile-mirrors.wml \
  $(TEMPLDIR)/template.wml $(ENGLISHSRCDIR)/volatile/volatile-mirrors.inc

ifeq "$(LANGUAGE)" "en"

$(ENGLISHSRCDIR)/volatile/volatile-mirrors.inc: \
  $(ENGLISHSRCDIR)/mirror/Mirrors.masterlist $(ENGLISHSRCDIR)/mirror/mirror_list.pl
	$(ENGLISHSRCDIR)/mirror/mirror_list.pl -m $(ENGLISHSRCDIR)/mirror/Mirrors.masterlist -t volatile-wml > volatile-mirrors.inc

mirrorstuff := etch-volatile.asc id_mirrorpush.pub mirror-volatile.sh

destmirrorstuff := $(patsubst %,$(HTMLDIR)/%,$(mirrorstuff))

install:: $(destmirrorstuff)

$(destmirrorstuff): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(destmirrorstuff)

endif
