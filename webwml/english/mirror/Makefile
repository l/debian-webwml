# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=mirror
SUBS=

include $(WMLBASE)/Make.lang


submit.$(LANGUAGE).html: submit.wml $(ENGLISHDIR)/mirror/submit.inc \
  $(ENGLISHSRCDIR)/releases/sid/archive.data  $(GETTEXTDEP) \
  $(TEMPLDIR)/countries.wml

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
  $(ENGLISHDIR)/mirror/official.data $(GETTEXTDEP)
list.$(LANGUAGE).html: list.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHDIR)/mirror/list-primary.inc \
  $(ENGLISHDIR)/mirror/list-secondary.inc \
  $(ENGLISHDIR)/mirror/list-footer.inc
list-full.$(LANGUAGE).html: list-full.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHDIR)/mirror/list-full.inc
list-non-US.$(LANGUAGE).html: list-non-US.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHDIR)/mirror/list-non-US.inc
size.$(LANGUAGE).html: size.wml $(ENGLISHDIR)/mirror/size.data

# there only needs to be one version of the following so
# the non-english directories shouldn't try to install them
ifeq "$(LANGUAGE)" "en"

# Note: the masterlist file is kept private since it contains e-mail addresses
mirrorstuff := anonftpsync \
  id_rsa.pub.ftp-master id_rsa.pub.syncproxy.eu id_rsa.pub.syncproxy.wna \

destmirrorstuff := $(patsubst %,$(HTMLDIR)/%,$(mirrorstuff))

install:: $(destmirrorstuff)

$(destmirrorstuff): $(HTMLDIR)/%: %
	install -m 664 -p $< $(HTMLDIR)

cleandest::
	rm -f $(destmirrorstuff)

.PHONY: text html full nonus $(ENGLISHDIR)/mirror/size.data 
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

$(ENGLISHDIR)/mirror/size.data: $(ENGLISHDIR)/mirror/arch_size.pl
	./arch_size.pl

$(ENGLISHDIR)/mirror/official_sponsors.list: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t officialsponsors > $@

$(ENGLISHDIR)/mirror/sponsors.list: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t sponsors > $@

$(ENGLISHDIR)/mirror/official.data: $(TEMPLDIR)/countries.wml \
  $(ENGLISHDIR)/mirror/Mirrors.masterlist

$(ENGLISHDIR)/mirror/list-primary.inc: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t wml-primary > $@

$(ENGLISHDIR)/mirror/list-secondary.inc: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t wml-secondary > $@

$(ENGLISHDIR)/mirror/list-full.inc: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t wml-full > $@

$(ENGLISHDIR)/mirror/list-non-US.inc: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t wml-nonus > $@

$(ENGLISHDIR)/mirror/list-footer.inc: \
  $(ENGLISHDIR)/mirror/mirror_list.pl $(ENGLISHDIR)/mirror/Mirrors.masterlist
	./mirror_list.pl -m Mirrors.masterlist -t wml-footer > $@

endif

.DELETE_ON_ERROR:
