
langs = ar ca da de el eo es fi fr hr hu id it ja ko lt nl no pl pt ro ru sv tr zh

LOCALEROOT = $(CURDIR)/locale
TEMPLDIR   = template/debian

TMPL_FILES = $(wildcard $(TEMPLDIR)/*.wml) $(TEMPLDIR)/countries.def
POFILES    = $(addprefix po-files/templates., $(addsuffix .po, $(langs)))
UPOFILES   = $(POFILES:.po=.upo)
GMOFILES   = $(POFILES:.po=.gmo)
POTFILES   = po-files/templates.pot

#  Aliases
pot: $(POTFILES)
update-po: $(UPOFILES)
gmo: $(GMOFILES)

$(POTFILES): $(TMPL_FILES)
	./scripts/wmlxgettext.pl $(TMPL_FILES) > po-files/templates.pot.new
	cd po-files && \
	  if [ -f templates.pot ]; then \
	    cmp templates.pot templates.pot.new >/dev/null 2>&1 \
	    || mv -f templates.pot.new templates.pot; \
	  else \
	    mv -f templates.pot.new templates.pot; \
	  fi
	-@rm -f po-files/templates.pot.new

po-files/templates.%.upo: $(POTFILES) po-files/templates.%.po
	-@cd po-files; \
   echo -n "Merging $* "; \
   msgmerge templates.$*.po templates.pot -o templates.$*.upo \
   || echo "Command failed: msgmerge templates.$*.po templates.pot"

po-files/templates.%.gmo: $(POTFILES) po-files/templates.%.upo
	-@echo Lang $*:
	-@cd po-files; \
   msgfmt --statistics -o templates.$*.gmo templates.$*.upo

install-gmo:
	cd po-files; langs='$(langs)'; \
   for l in $${langs}; do \
     [ -d $(LOCALEROOT)/$$l/LC_MESSAGES ] || mkdir -p $(LOCALEROOT)/$$l/LC_MESSAGES; \
     if [ -f $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo ]; then \
       cmp templates.$$l.gmo $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo >/dev/null 2>&1 \
       || cp -f templates.$$l.gmo $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo; \
     else \
       cp -f templates.$$l.gmo $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo; \
     fi; \
   done

clean:
	-@rm -f $(UPOFILES)
	-@rm -f $(GMOFILES)
	-@rm -f $(POTFILES)

#   Extract PO files from slices
init-po: $(TEMPLDIR)/countries.def
	langs='$(langs)'; \
   for l in $${langs}; do ./scripts/wml2po.pl $$l $(TMPL_FILES) > po-files/templates.$$l.po; done

fix-po:
	langs='$(langs)'; \
   for l in $${langs}; do \
     if [ "$$l" = ja ]; then \
       charset='euc-jp'; \
     else \
       charset=''; \
       for c in ../*/.wmlrc; do \
         grep CUR_ISO_LANG=$$l $$c >/dev/null 2>&1 \
         && charset=`grep CHARSET= $$c | sed -e 's/.*CHARSET=//'`; \
       done; \
     fi; \
     if [ "x$${charset}" = x ]; then \
       echo Unknown encoding for language $$l; \
     else \
       sed -e "3s/charset=\\([^\"\\\\]*\\)/charset=$${charset}/" -e 's/"\$$([A-Z]*)[^"]*"/"%s\\"/' po-files/templates.$$l.po > po-files/templates.$$l.po.new \
       && mv po-files/templates.$$l.po.new po-files/templates.$$l.po; \
     fi; \
   done

#   In WML files, replace slices with <gettext> tags
convert-templates:
	./scripts/wmlconvert.pl $(TMPL_FILES)
	for p in template/patches/*.patch; do patch -p0 < $$p; done
	-rm -f $(TEMPLDIR)/countries.def $(TEMPLDIR)/language_names.def
	$(MAKE) $(TEMPLDIR)/countries.def $(TEMPLDIR)/language_names.def

$(TEMPLDIR)/countries.def: $(TEMPLDIR)/countries.wml
	cd $(TEMPLDIR) && sed -e /^#/d countries.wml | eperl -B '<:' -E ':>' - >/dev/null

$(TEMPLDIR)/language_names.def: $(TEMPLDIR)/language_names.wml
	cd $(TEMPLDIR) && sed -e '/^#/d' -e '/^<:/,/^:>/!d' language_names.wml  | eperl -B '<:' -E ':>' - >/dev/null

