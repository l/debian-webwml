# This Makefile should need no changes from webwml/english/distrib/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=distrib
SUBS=

include $(WMLBASE)/Make.lang

books.$(LANGUAGE).html: books.wml $(ENGLISHSRCDIR)/distrib/books.def \
  $(TEMPLDIR)/countries.wml $(TEMPLDIR)/language_names.wml
ftplist.$(LANGUAGE).html: ftplist.wml $(ENGLISHSRCDIR)/distrib/ftplist.data \
  $(TEMPLDIR)/countries.wml
packages.$(LANGUAGE).html: packages.wml $(ENGLISHSRCDIR)/releases/info
pre-installed.$(LANGUAGE).html: pre-installed.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHSRCDIR)/distrib/pre-installed.data $(ENGLISHSRCDIR)/distrib/vendors.CD.def
vendors.$(LANGUAGE).html: vendors.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHSRCDIR)/distrib/vendors.CD $(ENGLISHSRCDIR)/distrib/vendors.CD.def

ftplist.data: ../mirror/Mirrors.masterlist
	echo -e "#use wml::debian::countries\n<define-tag ftpmirrors>\n<ul>" > $@
	for i in `grep-dctrl -n -F Site -s Site -r 'ftp\...\.debian.org' ../mirror/Mirrors.masterlist | sort`; do \
	  echo -e "<li><a href=\"http://$${i}`grep-dctrl -n -F Site -s Archive-http -X $$i ../mirror/Mirrors.masterlist`\"><`echo $$i | sed -e s/^ftp.// -e s/.debian.org$$// | tr a-z A-Z`c></a>" >> $@; \
	  echo -e " (<a href=\"ftp://$${i}`grep-dctrl -n -F Site -s Archive-ftp -X $$i ../mirror/Mirrors.masterlist`\">FTP</a>)" >> $@; \
	done
	echo -e "</ul>\n</define-tag>" >> $@
