# This Makefile should need no changes from webwml/english/mirror/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=mirror
SUBS=

include $(WMLBASE)/Make.lang


submit.$(LANGUAGE).html: submit.wml $(ENGLISHDIR)/mirror/countries.data \
  $(TEMPLDIR)/countries.wml
webmirror.$(LANGUAGE).html: webmirror.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHSRCDIR)/mirror/webmirrors.data
official_sponsors.$(LANGUAGE).html: official_sponsors.wml \
  $(TEMPLDIR)/template.wml $(ENGLISHDIR)/mirror/official_sponsors.list

# there only needs to be one version of the following so
# the non-english directories shouldn't try to install them
ifeq "$(LANGUAGE)" "en"

# Note: the masterlist file is kept private since it contains e-mail addresses
mirrorstuff := ftpsync ftpsync.conf websync websync.conf \
	identity.pub.master.ftp identity.pub.master.web \
	anonftpsync \
	ftpsync-non-US ftpsync-non-US.conf identity.pub.non-US.ftp
destmirrorstuff := $(patsubst %,$(HTMLDIR)/%,$(mirrorstuff))

install:: $(destmirrorstuff)

$(destmirrorstuff): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(destmirrorstuff)

.PHONY: text html full nonus
text: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t text
html: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t html
full: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t methods
nonus: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t nonus

$(ENGLISHDIR)/mirror/official_sponsors.list: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t sponsors > $@
endif
