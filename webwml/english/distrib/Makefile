# This Makefile should need no changes from webwml/english/distrib/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=distrib
SUBS=

GETTEXTFILES = distrib.mo

include $(WMLBASE)/Make.lang

archive.$(LANGUAGE).html: archive.wml $(ENGLISHDIR)/distrib/archive.mirrors \
  $(TEMPLDIR)/countries.wml
packages.$(LANGUAGE).html: packages.wml $(ENGLISHSRCDIR)/releases/info \
  $(ENGLISHDIR)/distrib/search_packages-form.inc \
  $(ENGLISHDIR)/distrib/search_contents-form.inc
pre-installed.$(LANGUAGE).html: pre-installed.wml $(TEMPLDIR)/countries.wml \
  $(ENGLISHDIR)/distrib/pre-installed.data $(ENGLISHDIR)/CD/vendors/vendors.CD.def
floppyinst.$(LANGUAGE).html: floppyinst.wml $(ENGLISHSRCDIR)/releases/info

ifeq "$(LANGUAGE)" "en"

$(ENGLISHSRCDIR)/distrib/archive.mirrors: archive.mirrors
archive.mirrors: ../mirror/Mirrors.masterlist
	echo "#use wml::debian::countries" > $@
	echo "<define-tag archivemirrors>" >> $@
	echo "<ul>" >> $@
	for i in `grep-dctrl -n -F Old-http,Old-ftp,Old-rsync -s Site -r '.' ../mirror/Mirrors.masterlist | sort`; do \
          xy=`grep-dctrl -n -F Site -s Country -X $$i ../mirror/Mirrors.masterlist | perl -pe 's/^(..) .*$$/$$1/' | head -1`; \
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
