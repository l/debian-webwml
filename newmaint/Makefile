# Makefile to build HTML + PHP files from WML files
# requires a checkout of webwml/template/debian from the webwml tree!

ifneq "$(wildcard ${HOME}/web-source/webwml/english/template)" ""
TEMPLDIR := ${HOME}/web-source/webwml/english/template/debian
else
TEMPLDIR := ../webwml/english/template/debian
endif
DEBTEMPLATES := $(wildcard $(TEMPLDIR)/*.wml) \
                $(TEMPLDIR)/countries.def \
                $(TEMPLDIR)/language_names.def \
                $(wildcard template/*.wml) \
                .wmlrc
TARGETDIR := ../../web

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(subst .wml,.html,$(shell egrep -L '(<\?|::gpgpage)' $(WMLFILES)))
PHPFILES := $(subst .wml,.php,$(shell egrep -l '(<\?|::gpgpage)' $(WMLFILES)))
INCFILES := $(wildcard *.inc)
DESTHTMLFILES := $(patsubst %,$(TARGETDIR)/%,$(HTMLFILES))
DESTPHPFILES := $(patsubst %,$(TARGETDIR)/%,$(PHPFILES))
DESTINCFILES := $(patsubst %,$(TARGETDIR)/%,$(INCFILES))

WML_DEFS := -I $(subst /debian,,$(TEMPLDIR))

all: $(HTMLFILES) $(PHPFILES)

%.html: %.wml $(DEBTEMPLATES)
	wml $(WML_DEFS) $< -o UNDEFuEN:$@

%.php: %.wml $(DEBTEMPLATES)
	wml $(WML_DEFS) $< -o UNDEFuEN:$@

install: $(DESTHTMLFILES) $(DESTPHPFILES) $(DESTINCFILES)

$(DESTHTMLFILES) $(DESTPHPFILES) $(DESTINCFILES): $(TARGETDIR)/%: %
	@test -d $(TARGETDIR) || mkdir -p $(TARGETDIR)
	install -m 644 -p $(@F) $(TARGETDIR)

rsync: $(HTMLFILES) $(PHPFILES)
	rsync -e ssh $(HTMLFILES) $(PHPFILES) $(INCFILES) nm.debian.org:/org/nm.debian.org/web

backup:
	rsync -e ssh -r template $(WMLFILES) $(INCFILES) Makefile nm.debian.org:/org/nm.debian.org/wml

clean:
	rm -f $(HTMLFILES) $(PHPFILES)

$(TEMPLDIR)/countries.def: $(TEMPLDIR)/countries.wml
	cd $(TEMPLDIR) && sed -e /^#/d countries.wml | eperl -B '<:' -E ':>' - >/dev/null

$(TEMPLDIR)/language_names.def: $(TEMPLDIR)/language_names.wml
	cd $(TEMPLDIR) && sed -e '/^#/d' -e '/^<:/,/^:>/!d' language_names.wml  | eperl -B '<:' -E ':>' - >/dev/null

.SUFFIXES:
