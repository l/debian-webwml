# This Makefile should need no changes from webwml/english/distrib/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=distrib
SUBS=

GETTEXTFILES = distrib.mo

include $(WMLBASE)/Make.lang

archive.$(LANGUAGE).html: archive.wml $(ENGLISHDIR)/distrib/archive.mirrors \
  $(ENGLISHDIR)/distrib/archive-nonus.mirrors \
  $(TEMPLDIR)/countries.wml
packages.$(LANGUAGE).html: packages.wml $(ENGLISHSRCDIR)/releases/info \
  $(ENGLISHDIR)/distrib/search_packages-form.inc \
  $(ENGLISHDIR)/distrib/search_contents-form.inc
pre-installed.$(LANGUAGE).html: pre-installed.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHDIR)/distrib/pre-installed.data $(ENGLISHDIR)/CD/vendors/vendors.CD.def

netinst.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
  $(TEMPLDIR)/toc.wml \
  $(ENGLISHSRCDIR)/releases/info \
  $(ENGLISHSRCDIR)/releases/images.data \

ifeq "$(LANGUAGE)" "en"
clean::
	rm -f archive.mirrors archive-nonus.mirrors

$(ENGLISHSRCDIR)/distrib/archive.mirrors: \
 $(ENGLISHSRCDIR)/mirror/Mirrors.masterlist $(ENGLISHSRCDIR)/mirror/mirror_list.pl
	echo "#use wml::debian::countries" > $@
	echo "<define-tag archivemirrors>" >> $@
	echo "<ul>" >> $@
	../mirror/mirror_list.pl -m ../mirror/Mirrors.masterlist -t compact-old >> $@
	echo "</ul>" >> $@
	echo "</define-tag>" >> $@

$(ENGLISHSRCDIR)/distrib/archive-nonus.mirrors: \
 $(ENGLISHSRCDIR)/mirror/Mirrors.masterlist $(ENGLISHSRCDIR)/mirror/mirror_list.pl
	echo "#use wml::debian::countries" > $@
	echo "<define-tag archivenonusmirrors>" >> $@
	echo "<ul>" >> $@
	../mirror/mirror_list.pl -m ../mirror/Mirrors.masterlist -t compact-nonus >> $@
	echo "</ul>" >> $@
	echo "</define-tag>" >> $@

.DELETE_ON_ERROR:

endif
