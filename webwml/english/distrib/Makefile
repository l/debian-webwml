# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=distrib
SUBS=

GETTEXTFILES = distrib.mo

include $(WMLBASE)/Make.lang

archive.$(LANGUAGE).html: archive.wml $(ENGLISHDIR)/distrib/archive.mirrors \
  $(ENGLISHDIR)/distrib/archive-nonus.mirrors \
  $(TEMPLDIR)/countries.wml
packages.$(LANGUAGE).html: packages.wml $(TEMPLDIR)/release_info.wml \
  $(ENGLISHDIR)/distrib/search_packages-form.inc \
  $(ENGLISHDIR)/distrib/search_contents-form.inc
pre-installed.$(LANGUAGE).html: pre-installed.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHDIR)/distrib/pre-installed.data $(ENGLISHDIR)/CD/vendors/vendors.CD.def

index.$(LANGUAGE).html: index.wml \
  $(TEMPLDIR)/release_info.wml \
  $(TEMPLDIR)/release_images.wml \

netinst.$(LANGUAGE).html: netinst.wml \
  $(TEMPLDIR)/toc.wml \
  $(TEMPLDIR)/release_info.wml \
  $(TEMPLDIR)/release_images.wml \

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
