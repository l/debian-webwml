# This Makefile should need no changes from webwml/english/distrib/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=distrib
SUBS=

include $(WMLBASE)/Make.lang

archive.$(LANGUAGE).html: archive.wml $(ENGLISHDIR)/distrib/archive.mirrors \
  $(TEMPLDIR)/countries.wml
ftplist.$(LANGUAGE).html: ftplist.wml $(ENGLISHSRCDIR)/distrib/ftplist.data \
  $(TEMPLDIR)/countries.wml
packages.$(LANGUAGE).html: packages.wml $(ENGLISHSRCDIR)/releases/info
pre-installed.$(LANGUAGE).html: pre-installed.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHDIR)/distrib/pre-installed.data $(ENGLISHDIR)/CD/vendors/vendors.CD.def

ifeq "$(LANGUAGE)" "en"
$(ENGLISHSRCDIR)/distrib/ftplist.data: ftplist.data
ftplist.data: ../mirror/Mirrors.masterlist
	echo "#use wml::debian::countries" > $@
	echo "<define-tag ftpmirrors>" >> $@
	echo "<ul>" >> $@
	for i in `grep-dctrl -n -F Site -s Site -r 'ftp\...\.debian.org' ../mirror/Mirrors.masterlist | sort`; do \
          xy=`echo $$i | sed -e s/^ftp.// -e s/.debian.org$$// | tr a-z A-Z`; \
          hpath=`grep-dctrl -n -F Site -s Archive-http -X $$i ../mirror/Mirrors.masterlist`; \
          fpath=`grep-dctrl -n -F Site -s Archive-ftp -X $$i ../mirror/Mirrors.masterlist`; \
	  echo "<li><a href=\"http://$${i}$${hpath}\"><$${xy}c></a>: " >> $@; \
          echo "<small>" >> $@; \
	  echo " <a href=\"http://$${i}$${hpath}\">HTTP</a>" >> $@; \
	  echo " <a href=\"ftp://$${i}$${fpath}\">FTP</a>" >> $@; \
          echo "</small>" >> $@; \
	done
	echo "</ul>" >> $@
	echo "</define-tag>" >> $@
	echo "<define-tag nonusmirrors>" >> $@
	echo "<ul>" >> $@
	for i in `grep-dctrl -n -F Site -s Site -r 'ftp\...\.debian.org' ../mirror/Mirrors.masterlist | sort`; do \
          hpath=`grep-dctrl -n -F Site -s NonUS-http -X $$i ../mirror/Mirrors.masterlist`; \
          fpath=`grep-dctrl -n -F Site -s NonUS-ftp -X $$i ../mirror/Mirrors.masterlist`; \
          xy=`echo $$i | sed -e s/^ftp.// -e s/.debian.org$$// | tr a-z A-Z`; \
          if [ "$$hpath" ]; then \
            echo "<li><a href=\"http://$${i}$${hpath}\"><$${xy}c></a>: " >> $@; \
            echo "<small>" >> $@; \
            echo " <a href=\"http://$${i}$${hpath}\">HTTP</a>" >> $@; \
            if [ "$$fpath" ]; then \
              echo " <a href=\"ftp://$${i}$${fpath}\">FTP</a>" >> $@; \
            fi; \
            echo "</small>" >> $@; \
          fi; \
        done
	echo "</ul>" >> $@
	echo "</define-tag>" >> $@

$(ENGLISHSRCDIR)/distrib/archive.mirrors: archive.mirrors
archive.mirrors: ../mirror/Mirrors.masterlist
	echo "#use wml::debian::countries" > $@
	echo "<define-tag archivemirrors>" >> $@
	echo "<ul>" >> $@
	for i in `grep-dctrl -n -F Old-http,Old-ftp,Old-rsync -s Site -r '.' ../mirror/Mirrors.masterlist | sort`; do \
          xy=`grep-dctrl -n -F Site -s Country -X $$i ../mirror/Mirrors.masterlist | perl -pe 's/^(..) .*$$/$$1/'`; \
	  echo "<li>$$i (<$${xy}c>): " >> $@; \
          http=`grep-dctrl -n -F Site -s Old-http -X $$i ../mirror/Mirrors.masterlist`; \
          if [ "$$http" != "" ]; then \
            echo "<a href=\"http://$${i}$${http}\">HTTP</a>" >> $@; \
          fi; \
          ftp=`grep-dctrl -n -F Site -s Old-ftp -X $$i ../mirror/Mirrors.masterlist`; \
          if [ "$$ftp" != "" ]; then \
            echo "<a href=\"ftp://$${i}$${ftp}\">FTP</a>" >> $@; \
          fi; \
          rsync=`grep-dctrl -n -F Site -s Old-rsync -X $$i ../mirror/Mirrors.masterlist`; \
          if [ "$$rsync" != "" ]; then \
            echo "rsync&nbsp;$${i}::$${rsync}" >> $@; \
          fi; \
          echo "</li>" >> $@; \
	done
	echo "</ul>" >> $@
	echo "</define-tag>" >> $@

.DELETE_ON_ERROR:

endif
