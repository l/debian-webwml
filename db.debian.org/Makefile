# special Makefile
# requires a checkout of webwml/template/debian from the webwml tree!

TEMPLDIR := ../../webwml/english/template/debian
DEBTEMPLATES := $(wildcard $(TEMPLDIR)/*.wml) \
                $(TEMPLDIR)/countries.def \
                $(TEMPLDIR)/language_names.def \
                $(wildcard template/*.wml) \
                .wmlrc
TARGETDIR := /var/www/userdir-ldap

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(subst .wml,.html,$(WMLFILES))
DESTHTMLFILES := $(patsubst %.wml,$(TARGETDIR)/%.html,$(WMLFILES))
OTHERFILES := $(wildcard *.cgi) $(wildcard *.cfg) $(wildcard *.tab)
DESTOTHERFILES := $(patsubst %,$(TARGETDIR)/%,$(OTHERFILES))

WML_DEFS := -I $(subst /debian,,$(TEMPLDIR))

all: $(HTMLFILES)

%.html: %.wml $(DEBTEMPLATES)
	wml $(WML_DEFS) $< -o UNDEFuEN:$@

install: $(DESTHTMLFILES) $(DESTOTHERFILES)

$(DESTHTMLFILES) $(DESTOTHERFILES): $(TARGETDIR)/%: %
	@test -d $(TARGETDIR) || mkdir -p $(TARGETDIR)
	install -m 644 -p $(@F) $(TARGETDIR)

clean:
	rm -f $(HTMLFILES)

$(TEMPLDIR)/countries.def: $(TEMPLDIR)/countries.wml
	cd $(TEMPLDIR) && sed -e /^#/d countries.wml | eperl -B '<:' -E ':>' - >/dev/null

$(TEMPLDIR)/language_names.def: $(TEMPLDIR)/language_names.wml
	cd $(TEMPLDIR) && sed -e '/^#/d' -e '/^<:/,/^:>/!d' language_names.wml  | eperl -B '<:' -E ':>' - >/dev/null

.SUFFIXES:
