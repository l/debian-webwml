
langs = ar ca da de el eo es fi fr hr hu id it ja ko nl no pl pt ro ru sv tr zh

LOCALEROOT = $(CURDIR)/locale

tmpl_files = $(wildcard template/debian/*.wml)

pot:
	./scripts/wmlxgettext.pl $(tmpl_files) > po-files/templates.pot.new
	cd po-files && \
	  if [ -f templates.pot ]; then \
	    cmp templates.pot templates.pot.new >/dev/null 2>&1 \
	    || mv -f templates.pot.new templates.pot; \
	  else \
	    mv -f templates.pot.new templates.pot; \
	  fi
	-@rm -f po-files/templates.pot.new

merge-po:
	cd po-files; langs='$(langs)'; \
   for l in $${langs}; do \
     if msgmerge templates.$$l.po templates.pot -o templates.$$l.po.new; then \
       mv -f templates.$$l.po.new templates.$$l.po; \
     else \
       echo "Command failed: msgmerge templates.$$l.po templates.pot"; \
       rm -f templates.$$l.po.new; \
     fi; \
   done

gmo:
	cd po-files; langs='$(langs)'; \
   for l in $${langs}; do \
     msgfmt --statistics -o templates.$$l.gmo templates.$$l.po; \
   done

install-gmo:
	cd po-files; langs='$(langs)'; \
   for l in $${langs}; do \
     [ -d $(LOCALEROOT)/$$l/LC_MESSAGES ] || mkdir -p $(LOCALEROOT)/$$l/LC_MESSAGES; \
     if [ -f $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo ]; then \
       cmp templates.$$l.gmo $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo \
       || cp -f templates.$$l.gmo $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo; \
     else \
       cp -f templates.$$l.gmo $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo; \
     fi; \
   done

clean:
	-rm -f po-files/*.gmo po-files/*.pot

#   Extract PO files from slices
init-po:
	langs='$(langs)'; \
   for l in $${langs}; do ./scripts/wml2po.pl $$l $(tmpl_files) > po-files/templates.$$l.po; done

fix-po:
	langs='$(langs)'; \
   for l in $${langs}; do \
     charset=''; \
     for c in ../*/.wmlrc; do \
       grep CUR_ISO_LANG=$$l $$c >/dev/null 2>&1 \
       && charset=`grep CHARSET= $$c | sed -e 's/.*CHARSET=//'`; \
     done; \
     if [ "x$${charset}" = x ]; then \
       echo Unknown encoding for language $$l; \
     else \
       sed -e "3s/CHARSET/$${charset}/" po-files/templates.$$l.po > po-files/templates.$$l.po.new \
       && mv po-files/templates.$$l.po.new po-files/templates.$$l.po; \
     fi; \
   done

#   In WML files, replace slices with <gettext> tags
convert-templates:
	./scripts/wmlconvert.pl $(tmpl_files)

