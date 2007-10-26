# This Makefile should need no changes from webwml/english/mirror/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=mirror
SUBS=

include $(WMLBASE)/Make.lang

submit.$(LANGUAGE).html: submit.wml $(ENGLISHDIR)/mirror/submit.inc \
  $(GETTEXTDEP)

ifeq "$(LANGUAGE)" "en"
$(ENGLISHDIR)/mirror/submit.inc: $(TEMPLDIR)/countries_all.wml \
  $(TEMPLDIR)/countries.wml $(ENGLISHDIR)/releases/sid/archive.data
endif

webmirror.$(LANGUAGE).html: webmirror.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHSRCDIR)/mirror/webmirrors.data $(GETTEXTDEP)
official_sponsors.$(LANGUAGE).html: official_sponsors.wml \
  $(TEMPLDIR)/template.wml $(ENGLISHDIR)/mirror/official_sponsors.list \
  $(GETTEXTDEP)
sponsors.$(LANGUAGE).html: sponsors.wml \
  $(TEMPLDIR)/template.wml $(ENGLISHDIR)/mirror/sponsors.list \
  $(TEMPLDIR)/countries.wml $(GETTEXTDEP)
ftpmirror.$(LANGUAGE).html: ftpmirror.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/toc.wml $(ENGLISHDIR)/releases/sid/archive.data $(GETTEXTDEP)
official.$(LANGUAGE).html: official.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHDIR)/mirror/Mirrors.masterlist \
  $(ENGLISHDIR)/mirror/official.data $(TEMPLDIR)/countries.wml \
  $(GETTEXTDEP)

# there only needs to be one version of the following so
# the non-english directories shouldn't try to install them
ifeq "$(LANGUAGE)" "en"

# Note: the masterlist file is kept private since it contains e-mail addresses
mirrorstuff := anonftpsync ftpsync.conf \
  id_rsa.pub.ftp-master id_rsa.pub.syncproxy.eu id_rsa.pub.syncproxy.wna \
  websync websync.conf id_dsa.pub.www-master
	
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
	@./mirror_list.pl -m Mirrors.masterlist -t fullmethods
nonus: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t nonus
nonushtml: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t nonushtml

$(ENGLISHDIR)/mirror/official_sponsors.list: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t officialsponsors > $@

$(ENGLISHDIR)/mirror/sponsors.list: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t sponsors > $@
endif

.DELETE_ON_ERROR:
