# This Makefile should need no changes from webwml/english/distrib/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=distrib
SUBS=

include $(WMLBASE)/Make.lang

ftplist.$(LANGUAGE).html: ftplist.wml $(ENGLISHSRCDIR)/distrib/ftplist.data \
  $(TEMPLDIR)/countries.wml
packages.$(LANGUAGE).html: packages.wml $(ENGLISHSRCDIR)/releases/info
pre-installed.$(LANGUAGE).html: pre-installed.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHSRCDIR)/distrib/pre-installed.data $(ENGLISHSRCDIR)/distrib/vendors.CD.def
vendors.$(LANGUAGE).html: vendors.wml $(TEMPLDIR)/countries.wml \
  $(TEMPLDIR)/url.wml \
  $(ENGLISHSRCDIR)/distrib/vendors.CD $(ENGLISHSRCDIR)/distrib/vendors.CD.def

ifeq "$(LANGUAGE)" "en"
$(ENGLISHSRCDIR)/distrib/ftplist.data: ftplist.data
ftplist.data: ../mirror/Mirrors.masterlist
	echo "#use wml::debian::countries" > $@
	echo "<define-tag ftpmirrors>" >> $@
	echo "<ul>" >> $@
	for i in `grep-dctrl -n -F Site -s Site -r 'ftp\...\.debian.org' ../mirror/Mirrors.masterlist | sort`; do \
          xy=`echo $$i | sed -e s/^ftp.// -e s/.debian.org$$// | tr a-z A-Z`; \
	  echo "<li><a href=\"http://$${i}`grep-dctrl -n -F Site -s Archive-http -X $$i ../mirror/Mirrors.masterlist`\"><$${xy}c></a>" >> $@; \
	  echo " (<a href=\"ftp://$${i}`grep-dctrl -n -F Site -s Archive-ftp -X $$i ../mirror/Mirrors.masterlist`\">FTP</a>)" >> $@; \
	done
	echo "</ul>" >> $@
	echo "</define-tag>" >> $@
	echo "<define-tag nonusmirrors>" >> $@
	echo "<ul>" >> $@
	for i in `grep-dctrl -n -F Site -s Site -r 'ftp\...\.debian.org' ../mirror/Mirrors.masterlist | sort`; do \
          ch=`grep-dctrl -n -F Site -s NonUS-http -X $$i ../mirror/Mirrors.masterlist`; \
          cf=`grep-dctrl -n -F Site -s NonUS-ftp -X $$i ../mirror/Mirrors.masterlist`; \
          xy=`echo $$i | sed -e s/^ftp.// -e s/.debian.org$$// | tr a-z A-Z`; \
          if [ "$$ch" ]; then \
            echo "<li><a href=\"http://$${i}$${ch}\"><$${xy}c></a>" >> $@; \
            if [ "$$cf" ]; then \
              echo " (<a href=\"ftp://$${i}$${cf}\">FTP</a>)" >> $@; \
            fi; \
          fi; \
        done
	echo "</ul>" >> $@
	echo "</define-tag>" >> $@
endif
