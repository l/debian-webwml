# This Makefile should need no changes from webwml/english/mirror/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=mirror
SUBS=

include $(WMLBASE)/Make.lang


submit.$(LANGUAGE).html: submit.wml $(ENGLISHDIR)/mirror/countries.data \
  $(TEMPLDIR)/countries_perl.wml
webmirror.$(LANGUAGE).html: webmirror.wml $(TEMPLDIR)/template.wml \
  $(ENGLISHSRCDIR)/mirror/webmirrors.data

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

.PHONY: text html
text: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t text
html: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t html
full: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t methods
nonus: mirror_list.pl Mirrors.masterlist
	@./mirror_list.pl -m Mirrors.masterlist -t nonus

$(ENGLISHSRCDIR)/mirror/webmirrors.data: webmirrors.data
webmirrors.data: Mirrors.masterlist
	echo -e "#use wml::debian::countries\n<define-tag webmirrors>\n<ul>" > $@
	for i in `grep-dctrl -n -F Site -s Site -r 'www\...\.debian.org' Mirrors.masterlist | sort`; do \
          xy=`echo $$i | sed -e s/^www.// -e s/.debian.org$$// | tr a-z A-Z`; \
	  echo -e "<li><a href=\"http://$${i}`grep-dctrl -n -F Site -s WWW-http -X $$i Mirrors.masterlist`\"><$${xy}c></a>" >> $@; \
	done
	echo -e "</ul>\n</define-tag>" >> $@

endif
