
langs = ar ca da de el eo es fi fr hr hu id it ja ko lt nl no pl pt ro ru sv tr zh

LOCALEROOT = $(CURDIR)/../locale

TEMPLDIR   = template/debian

TEMPLATES_FILES = $(wildcard $(TEMPLDIR)/*.wml $(TEMPLDIR)/weeklynews/*.wml) $(TEMPLDIR)/countries.def
TEMPLATES_POT   = po-files/templates.pot
TEMPLATES_PO    = $(addprefix po-files/templates., $(addsuffix .po, $(langs)))
TEMPLATES_UPO   = $(TEMPLATES_PO:.po=.upo)
TEMPLATES_MO    = $(TEMPLATES_PO:.po=.mo)

PORTSDIR   = ports

PORTS_FILES     = $(PORTSDIR)/menu.defs $(PORTSDIR)/mips/cpu.data $(wildcard $(PORTSDIR)/*/menu.inc)
PORTS_POT       = po-files/ports.pot
PORTS_PO        = $(addprefix po-files/ports., $(addsuffix .po, $(langs)))
PORTS_UPO       = $(PORTS_PO:.po=.upo)
PORTS_MO        = $(PORTS_PO:.po=.mo)

#  Aliases
pot: $(TEMPLATES_POT) $(PORTS_POT)
update-po: $(TEMPLATES_UPO) $(PORTS_UPO)
mo: $(TEMPLATES_MO) $(PORTS_MO)

$(TEMPLATES_POT): $(TEMPLATES_FILES)
	./scripts/wmlxgettext.pl -p =english/ $(TEMPLATES_FILES) > $@

$(PORTS_POT): $(PORTS_FILES)
	./scripts/wmlxgettext.pl -p =english/ $(PORTS_FILES) > $@

po-files/templates.%.upo: $(TEMPLATES_POT) po-files/templates.%.po
	-@cd po-files; \
   echo -n "Merging $* "; \
   msgmerge templates.$*.po templates.pot -o templates.$*.upo \
   || echo "Command failed: msgmerge templates.$*.po templates.pot"

po-files/ports.%.upo: $(PORTS_POT) po-files/ports.%.po
	-@cd po-files; \
   echo -n "Merging $* "; \
   msgmerge ports.$*.po ports.pot -o ports.$*.upo \
   || echo "Command failed: msgmerge ports.$*.po ports.pot"

po-files/templates.%.mo: $(TEMPLATES_POT) po-files/templates.%.upo
	-@echo Stats for templates.$*:
	-@cd po-files; \
   msgfmt --statistics -o templates.$*.mo templates.$*.upo

po-files/ports.%.mo: $(PORTS_POT) po-files/ports.%.upo
	-@echo Stats for ports.$*:
	-@cd po-files; \
   msgfmt --statistics -o ports.$*.mo ports.$*.upo

install-mo:
	cd po-files; langs='$(langs)'; \
   for l in $${langs}; do \
     [ -d $(LOCALEROOT)/$$l/LC_MESSAGES ] || mkdir -p $(LOCALEROOT)/$$l/LC_MESSAGES; \
     if [ -f $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo ]; then \
       cmp templates.$$l.mo $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo >/dev/null 2>&1 \
       || cp -f templates.$$l.mo $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo; \
     else \
       cp -f templates.$$l.mo $(LOCALEROOT)/$$l/LC_MESSAGES/templates.mo; \
     fi; \
     if [ -f $(LOCALEROOT)/$$l/LC_MESSAGES/ports.mo ]; then \
       cmp ports.$$l.mo $(LOCALEROOT)/$$l/LC_MESSAGES/ports.mo >/dev/null 2>&1 \
       || cp -f ports.$$l.mo $(LOCALEROOT)/$$l/LC_MESSAGES/ports.mo; \
     else \
       cp -f ports.$$l.mo $(LOCALEROOT)/$$l/LC_MESSAGES/ports.mo; \
     fi; \
   done

install-po:
	cd po-files; langs='$(langs)'; \
   for l in $${langs}; do \
     lang=`grep -l CUR_ISO_LANG=$$l ../../*/.wmlrc | sed -e 's/\/\.wmlrc//' -e 's/.*\///'`; \
     [ ".$${lang}" = . ] && exit 1; \
     cp templates.$$l.upo ../../$${lang}/po/templates.$$l.po; \
     cp ports.$$l.upo ../../$${lang}/po/ports.$$l.po; \
   done

clean:
	-@rm -f $(TEMPLATES_UPO) $(TEMPLATES_MO) $(TEMPLATES_POT)
	-@rm -f $(PORTS_UPO) $(PORTS_MO) $(PORTS_POT)

#   Extract PO files from slices
init-po:
	langs='$(langs)'; \
   for l in $${langs}; do \
     ./scripts/wml2po.pl $$l $(TEMPLATES_FILES) > po-files/templates.$$l.po; \
     ./scripts/wml2po.pl $$l $(PORTS_FILES) > po-files/ports.$$l.po; \
   done

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
       sed -e "3s/charset=\\([^\"\\\\]*\\)/charset=$${charset}/" -e 's/"\$$([A-Z]*)[^"]*"/"%s\\"/' po-files/ports.$$l.po > po-files/ports.$$l.po.new \
       && mv po-files/ports.$$l.po.new po-files/ports.$$l.po; \
     fi; \
   done

#   In WML files, replace slices with <gettext> tags
convert-templates:
	./scripts/wmlconvert.pl $(PORTS_FILES)
	./scripts/wmlconvert.pl $(TEMPLATES_FILES)
	for p in template/patches/*.patch; do patch -p0 < $$p; done
	-rm -f $(TEMPLDIR)/countries.def $(TEMPLDIR)/language_names.def
	$(MAKE) $(TEMPLDIR)/countries.def $(TEMPLDIR)/language_names.def

$(TEMPLDIR)/countries.def: $(TEMPLDIR)/countries.wml
	cd $(TEMPLDIR) && sed -e /^#/d countries.wml | eperl -B '<:' -E ':>' - >/dev/null

$(TEMPLDIR)/language_names.def: $(TEMPLDIR)/language_names.wml
	cd $(TEMPLDIR) && sed -e '/^#/d' -e '/^<:/,/^:>/!d' language_names.wml  | eperl -B '<:' -E ':>' - >/dev/null

